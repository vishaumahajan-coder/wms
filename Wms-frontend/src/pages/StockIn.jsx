import React, { useState, useEffect, useCallback, useRef } from 'react';
import { Select, InputNumber, Button, Tag, Spin, Card, Empty, Tooltip } from 'antd';
import {
    ArrowUpOutlined, CheckCircleOutlined, WarningOutlined,
    ReloadOutlined, BarcodeOutlined, ScanOutlined
} from '@ant-design/icons';
import { MainLayout } from '../components/layout/MainLayout';
import { useAuthStore } from '../store/authStore';
import { apiRequest } from '../api/client';

function StockBadge({ qty }) {
    if (qty === null || qty === undefined) return null;
    if (qty <= 0) return <Tag color="red" icon={<WarningOutlined />}>Out of Stock</Tag>;
    if (qty <= 50) return <Tag color="orange" icon={<WarningOutlined />}>Low Stock</Tag>;
    return <Tag color="green" icon={<CheckCircleOutlined />}>In Stock</Tag>;
}

export default function StockIn() {
    const { token } = useAuthStore();
    const barcodeRef = useRef(null);
    const qtyRef = useRef(null);

    const [products, setProducts] = useState([]);
    const [warehouses, setWarehouses] = useState([]);
    const [loadingDeps, setLoadingDeps] = useState(true);

    // Form State
    const [selectedProduct, setSelectedProduct] = useState(null);
    const [selectedWarehouse, setSelectedWarehouse] = useState(null);
    const [selectedLocation, setSelectedLocation] = useState(null);
    const [selectedClient, setSelectedClient] = useState(null);
    const [batchNumber, setBatchNumber] = useState('');
    const [bestBeforeDate, setBestBeforeDate] = useState(null);
    const [locations, setLocations] = useState([]);
    const [clients, setClients] = useState([]);
    const [qty, setQty] = useState(1);
    const [processing, setProcessing] = useState(false);
    const [currentStock, setCurrentStock] = useState(null);
    const [loadingStock, setLoadingStock] = useState(false);

    // Barcode scanner state
    const [barcodeInput, setBarcodeInput] = useState('');
    const [barcodeMode, setBarcodeMode] = useState(false);

    // History from API
    const [history, setHistory] = useState([]);
    const [loadingHistory, setLoadingHistory] = useState(false);

    const fetchDeps = useCallback(async () => {
        if (!token) return;
        setLoadingDeps(true);
        try {
            const [prodRes, whRes, locRes, clRes] = await Promise.all([
                apiRequest('/api/inventory/products', { method: 'GET' }, token),
                apiRequest('/api/warehouses', { method: 'GET' }, token),
                apiRequest('/api/locations', { method: 'GET' }, token),
                apiRequest('/api/orders/customers', { method: 'GET' }, token),
            ]);
            setProducts(Array.isArray(prodRes.data) ? prodRes.data : []);
            setWarehouses(Array.isArray(whRes.data) ? whRes.data : []);
            setLocations(Array.isArray(locRes.data) ? locRes.data : []);
            setClients(Array.isArray(clRes.data) ? clRes.data : []);
        } catch {
            setProducts([]); setWarehouses([]); setLocations([]); setClients([]);
        } finally {
            setLoadingDeps(false);
        }
    }, [token]);

    const fetchHistory = useCallback(async () => {
        if (!token) return;
        setLoadingHistory(true);
        try {
            const res = await apiRequest('/api/inventory/adjustments?limit=30', { method: 'GET' }, token);
            const all = Array.isArray(res.data) ? res.data : [];
            // Show only SCAN_IN or positive adjustments
            setHistory(all.filter(a => a.quantity > 0 || a.reason === 'SCAN_IN').slice(0, 20));
        } catch {
            setHistory([]);
        } finally {
            setLoadingHistory(false);
        }
    }, [token]);

    useEffect(() => { fetchDeps(); fetchHistory(); }, [fetchDeps, fetchHistory]);

    const fetchCurrentStock = useCallback(async () => {
        if (!token || !selectedProduct || !selectedWarehouse || !selectedLocation) { setCurrentStock(null); return; }
        setLoadingStock(true);
        try {
            const query = `/api/inventory/stock?productId=${selectedProduct}&warehouseId=${selectedWarehouse}&locationId=${selectedLocation}`;
            const res = await apiRequest(query, { method: 'GET' }, token);
            const stocks = Array.isArray(res.data) ? res.data : [];
            const total = stocks.reduce((sum, row) => sum + (Number(row.quantity) || 0), 0);
            setCurrentStock(total);
        } catch { setCurrentStock(null); }
        finally { setLoadingStock(false); }
    }, [token, selectedProduct, selectedWarehouse, selectedLocation]);

    useEffect(() => { fetchCurrentStock(); }, [fetchCurrentStock]);

    // Barcode scan handler
    const handleBarcodeKeyDown = (e) => {
        if (e.key === 'Enter' && barcodeInput.trim()) {
            const scanned = barcodeInput.trim().toLowerCase();
            const match = products.find(p =>
                p.sku?.toLowerCase() === scanned ||
                p.barcode?.toLowerCase() === scanned
            );
            if (match) {
                setSelectedProduct(match.id);
                setBarcodeInput('');
                setTimeout(() => qtyRef.current?.focus(), 100);
            }
        }
    };

    const handleSubmit = async () => {
        if (!selectedProduct || !selectedWarehouse || !selectedLocation || !selectedClient || !qty || !batchNumber || !bestBeforeDate) {
            return message.error("Please fill all mandatory fields (Product, WH, Bin, Client, Batch, Expiry, Qty)");
        }
        setProcessing(true);
        try {
            await apiRequest('/api/inventory/adjustments', {
                method: 'POST',
                body: JSON.stringify({
                    productId: selectedProduct,
                    warehouseId: selectedWarehouse,
                    locationId: selectedLocation,
                    clientId: selectedClient,
                    batchNumber: batchNumber,
                    bestBeforeDate: bestBeforeDate.format('YYYY-MM-DD'),
                    quantity: Math.abs(qty),
                    type: 'INCREASE',
                    reason: 'SCAN_IN',
                })
            }, token);

            message.success("Stock added successfully");
            setQty(1);
            fetchCurrentStock();
            fetchHistory();
            setTimeout(() => barcodeRef.current?.focus(), 100);
        } catch (err) {
            message.error(err.message || "Failed to process stock in");
        } finally {
            setProcessing(false);
        }
    };

    const prodOptions = products.map(p => ({ value: p.id, label: `[${p.sku}] ${p.name}` }));
    const whOptions = warehouses.map(w => ({ value: w.id, label: w.name }));
    const filteredLocations = selectedWarehouse ? locations.filter(l => l.warehouseId === selectedWarehouse) : [];

    if (loadingDeps) return <MainLayout><div className="flex items-center justify-center min-h-[60vh]"><Spin size="large" /></div></MainLayout>;

    return (
        <MainLayout>
            <div className="flex gap-6 max-w-7xl mx-auto mt-2 pb-10 px-4">

                {/* LEFT — Scan form */}
                <div className="w-[480px] shrink-0 space-y-4">
                    {/* Header */}
                    <div className="bg-gradient-to-br from-green-600 to-emerald-700 rounded-2xl p-6 text-white shadow-lg border border-emerald-500/20">
                        <div className="flex items-center gap-4">
                            <div className="w-12 h-12 bg-white/10 rounded-2xl flex items-center justify-center border border-white/20">
                                <ArrowUpOutlined className="text-2xl" />
                            </div>
                            <div>
                                <h1 className="text-2xl font-black italic uppercase tracking-tight">Stock Receipt</h1>
                                <p className="text-emerald-100 text-[10px] font-bold uppercase tracking-widest mt-1">Receive & Track Expiry</p>
                            </div>
                        </div>
                    </div>

                    <Card className="rounded-2xl shadow-sm border-gray-100" styles={{ body: { padding: 24 } }}>
                        <div className="space-y-4">

                            {/* Barcode Scanner */}
                            <div>
                                <label className="text-[10px] font-black text-slate-400 uppercase tracking-widest block mb-2 ml-1">Quick Scan / SKU</label>
                                <div className="relative">
                                    <input
                                        ref={barcodeRef}
                                        value={barcodeInput}
                                        onChange={e => setBarcodeInput(e.target.value)}
                                        onKeyDown={handleBarcodeKeyDown}
                                        placeholder="Scan barcode or enter SKU..."
                                        className="w-full border border-gray-200 rounded-xl px-4 py-3 text-sm font-mono bg-slate-50 focus:outline-none focus:border-green-500 focus:bg-white transition-all pl-10 h-14"
                                    />
                                    <ScanOutlined className="absolute left-3.5 top-1/2 -translate-y-1/2 text-slate-300 text-lg" />
                                </div>
                            </div>

                            {/* Product Info Banner */}
                            {selectedProduct && (() => {
                                const prod = products.find(p => p.id === selectedProduct);
                                return prod ? (
                                    <div className="bg-emerald-50 p-4 rounded-xl border border-emerald-100 relative overflow-hidden">
                                        <div className="absolute top-0 right-0 p-2 opacity-5"><InboxOutlined className="text-6xl -mr-4 -mt-4" /></div>
                                        <p className="font-black text-emerald-900 text-lg leading-tight uppercase italic">{prod.name}</p>
                                        <div className="flex gap-2 mt-2">
                                            <span className="text-[10px] bg-white border border-emerald-200 text-emerald-700 px-2 py-0.5 rounded font-black">SKU: {prod.sku}</span>
                                        </div>
                                    </div>
                                ) : null;
                            })()}

                            {/* Main Selection */}
                            <div className="grid grid-cols-1 gap-4">
                                <div>
                                    <label className="text-[10px] font-black text-slate-400 uppercase tracking-widest block mb-1.5 ml-1">Product</label>
                                    <Select
                                        showSearch optionFilterProp="label"
                                        placeholder="Search product..."
                                        className="w-full" size="large"
                                        value={selectedProduct}
                                        onChange={setSelectedProduct}
                                        options={prodOptions}
                                    />
                                </div>

                                <div className="grid grid-cols-2 gap-3">
                                    <div>
                                        <label className="text-[10px] font-black text-slate-400 uppercase tracking-widest block mb-1.5 ml-1">Warehouse</label>
                                        <Select
                                            placeholder="WH"
                                            className="w-full" size="large"
                                            value={selectedWarehouse}
                                            onChange={(v) => { setSelectedWarehouse(v); setSelectedLocation(null); }}
                                            options={whOptions}
                                        />
                                    </div>
                                    <div>
                                        <label className="text-[10px] font-black text-slate-400 uppercase tracking-widest block mb-1.5 ml-1">Bin / Location</label>
                                        <Select
                                            placeholder="Location"
                                            className="w-full" size="large"
                                            value={selectedLocation}
                                            onChange={setSelectedLocation}
                                            disabled={!selectedWarehouse}
                                            options={filteredLocations.map(l => ({ value: l.id, label: l.name || l.code }))}
                                        />
                                    </div>
                                </div>

                                <div>
                                    <label className="text-[10px] font-black text-slate-400 uppercase tracking-widest block mb-1.5 ml-1">Client / Project</label>
                                    <Select
                                        placeholder="Select client..."
                                        className="w-full" size="large"
                                        value={selectedClient}
                                        onChange={setSelectedClient}
                                        options={clients.map(c => ({ value: c.id, label: c.name }))}
                                    />
                                </div>

                                <div className="pt-2 border-t border-slate-100 flex items-center justify-between">
                                    <span className="text-[10px] font-bold text-slate-500 uppercase">Tracking Details</span>
                                    <div className="h-px bg-slate-100 flex-1 ml-4 mr-1"></div>
                                </div>

                                <div className="grid grid-cols-2 gap-3">
                                    <div>
                                        <label className="text-[10px] font-black text-slate-400 uppercase tracking-widest block mb-1.5 ml-1">Batch Number <span className="text-rose-500">*</span></label>
                                        <Input
                                            placeholder="e.g. B-001"
                                            size="large"
                                            value={batchNumber}
                                            onChange={e => setBatchNumber(e.target.value)}
                                            className="rounded-xl"
                                        />
                                    </div>
                                    <div>
                                        <label className="text-[10px] font-black text-slate-400 uppercase tracking-widest block mb-1.5 ml-1">Expiry Date <span className="text-rose-500">*</span></label>
                                        <DatePicker
                                            className="w-full rounded-xl"
                                            size="large"
                                            placeholder="Select date"
                                            format="DD/MM/YYYY"
                                            value={bestBeforeDate}
                                            onChange={setBestBeforeDate}
                                        />
                                    </div>
                                </div>

                                <div>
                                    <label className="text-[10px] font-black text-slate-400 uppercase tracking-widest block mb-1.5 ml-1">Quantity</label>
                                    <InputNumber
                                        ref={qtyRef}
                                        min={1}
                                        value={qty}
                                        onChange={setQty}
                                        size="large"
                                        className="w-full rounded-xl font-black text-lg"
                                        controls
                                    />
                                </div>
                            </div>

                            {/* Submit */}
                            <button
                                onClick={handleSubmit}
                                disabled={processing || !selectedProduct || !selectedWarehouse || !selectedLocation || !selectedClient || !qty || !batchNumber || !bestBeforeDate}
                                className="w-full h-14 rounded-2xl text-white text-base font-black bg-emerald-600 hover:bg-emerald-700 active:scale-[0.98] transition-all shadow-lg shadow-emerald-100 disabled:opacity-40 disabled:cursor-not-allowed uppercase tracking-wide mt-2"
                            >
                                {processing ? '⏳ SYNCING...' : `✅ CONFIRM RECEIPT — ${qty || 0} units`}
                            </button>
                        </div>
                    </Card>
                </div>

                {/* RIGHT — History */}
                <div className="flex-1 min-w-0">
                    <Card
                        className="rounded-2xl shadow-sm h-full"
                        title={
                            <div className="flex items-center justify-between">
                                <span className="font-bold text-gray-800">Stock In History</span>
                                <Button size="small" icon={<ReloadOutlined />} onClick={fetchHistory} loading={loadingHistory}>Refresh</Button>
                            </div>
                        }
                        bodyStyle={{ padding: 0 }}
                    >
                        {loadingHistory ? (
                            <div className="flex items-center justify-center py-16"><Spin /></div>
                        ) : history.length === 0 ? (
                            <div className="py-16"><Empty description="No stock-in records yet" /></div>
                        ) : (
                            <div className="divide-y divide-gray-100 max-h-[calc(100vh-240px)] overflow-y-auto">
                                {history.map((entry, idx) => {
                                    // Backend puts product into items[0].product
                                    const prod = entry.items?.[0]?.product || entry.Product || {};
                                    const prodName = prod.name || entry.productName || 'Unknown Product';
                                    const sku = prod.sku || '';
                                    const barcode = prod.barcode || '';
                                    const whName = entry.Warehouse?.name || entry.warehouseName || '—';
                                    const dateStr = entry.createdAt ? new Date(entry.createdAt).toLocaleString() : '—';
                                    const displayQty = Math.abs(entry.quantity || entry.items?.[0]?.quantity || 0);
                                    return (
                                        <div key={entry.id || idx} className="flex items-center gap-4 px-5 py-3 hover:bg-gray-50 transition-colors">
                                            <div className="w-12 h-12 rounded-xl bg-green-100 flex items-center justify-center font-black text-green-600 text-lg shrink-0">
                                                +{displayQty}
                                            </div>
                                            <div className="flex-1 min-w-0">
                                                <p className="font-semibold text-gray-800 text-sm truncate">{prodName}</p>
                                                <div className="flex flex-wrap gap-1 mt-0.5">
                                                    {sku && <span className="text-[10px] bg-gray-100 text-gray-600 px-1.5 py-0.5 rounded font-mono">SKU: {sku}</span>}
                                                    {barcode && <span className="text-[10px] bg-blue-50 text-blue-600 px-1.5 py-0.5 rounded font-mono">Barcode: {barcode}</span>}
                                                    <span className="text-[10px] text-gray-400">{whName}</span>
                                                </div>
                                            </div>
                                            <div className="text-right shrink-0">
                                                <Tag color="green" className="text-xs font-bold">▲ IN +{displayQty}</Tag>
                                                <p className="text-[11px] text-gray-400 mt-0.5">{dateStr}</p>
                                            </div>
                                        </div>
                                    );
                                })}
                            </div>
                        )}
                    </Card>
                </div>
            </div>
        </MainLayout>
    );
}
