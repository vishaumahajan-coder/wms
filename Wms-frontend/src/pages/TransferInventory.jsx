import React, { useState, useEffect, useCallback, useRef } from 'react';
import { Select, InputNumber, Button, Tag, Spin, Card, Empty, Tooltip, DatePicker, Divider, Input, App, Space } from 'antd';

import {
    SwapOutlined, CheckCircleOutlined, WarningOutlined,
    ReloadOutlined, BarcodeOutlined, ScanOutlined,
    EnvironmentOutlined, TeamOutlined, TagOutlined,
    FileTextOutlined, ArrowRightOutlined
} from '@ant-design/icons';
import dayjs from 'dayjs';
import { MainLayout } from '../components/layout/MainLayout';
import { useAuthStore } from '../store/authStore';
import { canCreate, canUpdate, isAdmin } from '../permissions';
import { apiRequest } from '../api/client';
import { formatQuantity } from '../utils';

function StockBadge({ qty }) {
    if (qty === null || qty === undefined) return null;
    if (qty <= 0) return <Tag color="red" icon={<WarningOutlined />} className="rounded-full font-black text-[10px]">OUT OF STOCK</Tag>;
    if (qty <= 50) return <Tag color="orange" icon={<WarningOutlined />} className="rounded-full font-black text-[10px]">LOW STOCK</Tag>;
    return <Tag color="green" icon={<CheckCircleOutlined />} className="rounded-full font-black text-[10px]">IN STOCK</Tag>;
}


export default function TransferInventory() {
    const { token, user } = useAuthStore();
    const { message } = App.useApp();
    const barcodeRef = useRef(null);
    const qtyRef = useRef(null);

    // Dependencies
    const [products, setProducts] = useState([]);
    const [warehouses, setWarehouses] = useState([]);
    const [locations, setLocations] = useState([]);
    const [clients, setClients] = useState([]);
    const [loadingDeps, setLoadingDeps] = useState(true);

    // Form State
    const [selectedProduct, setSelectedProduct] = useState(null);
    const [fromWarehouse, setFromWarehouse] = useState(null);
    const [toWarehouse, setToWarehouse] = useState(null);
    const [fromLocation, setFromLocation] = useState(null);
    const [toLocation, setToLocation] = useState(null);
    const [selectedClient, setSelectedClient] = useState(null);
    const [qty, setQty] = useState(1);
    const [batchNumber, setBatchNumber] = useState('');
    const [bestBeforeDate, setBestBeforeDate] = useState(null);
    const [reason, setReason] = useState('');

    // UI State
    const [barcodeInput, setBarcodeInput] = useState('');
    const [processing, setProcessing] = useState(false);
    const [currentStock, setCurrentStock] = useState(null);
    const [loadingStock, setLoadingStock] = useState(false);
    const [history, setHistory] = useState([]);
    const [loadingHistory, setLoadingHistory] = useState(false);
    const [stockBreakdown, setStockBreakdown] = useState([]);
    const [loadingBreakdown, setLoadingBreakdown] = useState(false);
    const [historyCollapsed, setHistoryCollapsed] = useState(false);
    const isTruthyYes = (value) => ['yes', 'true'].includes(String(value || '').toLowerCase());



    const fetchDeps = useCallback(async () => {
        if (!token) return;
        setLoadingDeps(true);
        try {
            const [prodRes, whRes, locRes, clRes] = await Promise.all([
                apiRequest('/api/inventory/products', { method: 'GET' }, token),
                apiRequest('/api/warehouses', { method: 'GET' }, token),
                apiRequest('/api/locations', { method: 'GET' }, token),
                apiRequest('/api/orders/customers', { method: 'GET' }, token).catch(() => ({ data: [] })),
            ]);
            setProducts(Array.isArray(prodRes.data) ? prodRes.data : []);
            setWarehouses(Array.isArray(whRes.data) ? whRes.data : []);
            setLocations(Array.isArray(locRes.data) ? locRes.data : []);
            setClients(Array.isArray(clRes.data) ? clRes.data : []);
        } catch (err) {
            console.error("Failed to fetch dependencies", err);
        } finally {
            setLoadingDeps(false);
        }
    }, [token]);

    const fetchHistory = useCallback(async () => {
        if (!token) return;
        setLoadingHistory(true);
        try {
            // Fetch adjustments/logs that are transfers
            const res = await apiRequest('/api/inventory/logs?type=TRANSFER&limit=20', { method: 'GET' }, token);
            setHistory(Array.isArray(res.data) ? res.data : []);
        } catch {
            setHistory([]);
        } finally {
            setLoadingHistory(false);
        }
    }, [token]);

    const fetchCurrentStock = useCallback(async () => {
        if (!token || !selectedProduct || !fromWarehouse || !fromLocation) { setCurrentStock(null); return; }
        setLoadingStock(true);
        try {
            const query = `/api/inventory/stock?productId=${selectedProduct}&warehouseId=${fromWarehouse}&locationId=${fromLocation}`;
            const res = await apiRequest(query, { method: 'GET' }, token);
            const stocks = Array.isArray(res.data) ? res.data : [];
            const total = stocks.reduce((sum, row) => sum + (Number(row.quantity) || 0), 0);
            setCurrentStock(total);
        } catch { setCurrentStock(null); }
        finally { setLoadingStock(false); }
    }, [token, selectedProduct, fromWarehouse, fromLocation]);

    const fetchStockBreakdown = useCallback(async () => {
        if (!token || !selectedProduct) { setStockBreakdown([]); return; }
        setLoadingBreakdown(true);
        try {
            const query = fromWarehouse
                ? `/api/inventory/stock?productId=${selectedProduct}&warehouseId=${fromWarehouse}`
                : `/api/inventory/stock?productId=${selectedProduct}`;
            const res = await apiRequest(query, { method: 'GET' }, token);
            setStockBreakdown(Array.isArray(res.data) ? res.data : []);
        } catch { setStockBreakdown([]); }
        finally { setLoadingBreakdown(false); }
    }, [token, selectedProduct, fromWarehouse]);

    useEffect(() => { fetchDeps(); fetchHistory(); }, [fetchDeps, fetchHistory]);

    // Fetch breakdown when product or warehouse changes
    useEffect(() => {
        fetchStockBreakdown();
    }, [fetchStockBreakdown]);

    // Fetch current stock when selection changes
    useEffect(() => {
        fetchCurrentStock();
    }, [fetchCurrentStock]);
    // Auto-match as they type (for speed)
    useEffect(() => {
        if (!barcodeInput.trim()) return;
        const scanned = barcodeInput.trim().toLowerCase();
        const match = products.find(p =>
            p.sku?.toLowerCase() === scanned ||
            p.barcode === scanned
        );
        if (match) {
            handleProductSelect(match.id);
            setBarcodeInput('');
            message.success(`Recognized: ${match.name}`);
        }
    }, [barcodeInput, products]);

    const handleBarcodeKeyDown = (e) => {
        if (e.key === 'Enter' && barcodeInput.trim()) {
            const scanned = barcodeInput.trim().toLowerCase();
            const match = products.find(p =>
                p.sku?.toLowerCase() === scanned ||
                p.barcode === scanned
            );
            if (match) {
                setBarcodeInput('');
                message.success(`Scanned: ${match.name}`);
                handleProductSelect(match.id);
            } else {
                message.warning("Product not found in system");
            }
        }
    };

    const handleProductSelect = async (prodId) => {
        setSelectedProduct(prodId);
        const prod = products.find(p => p.id === prodId);
        if (prod) setBarcodeInput(prod.barcode || prod.sku || '');


        try {
            const res = await apiRequest(`/api/inventory/stock?productId=${prodId}`, { method: 'GET' }, token);
            const stocks = Array.isArray(res.data) ? res.data : [];

            if (stocks.length > 0) {
                const bestMatch = [...stocks].sort((a, b) => b.quantity - a.quantity)[0];
                if (bestMatch.warehouseId) setFromWarehouse(bestMatch.warehouseId);
                if (bestMatch.locationId) setFromLocation(bestMatch.locationId);
                if (bestMatch.clientId) setSelectedClient(bestMatch.clientId);
                if (bestMatch.batchNumber) setBatchNumber(bestMatch.batchNumber);
                if (bestMatch.bestBeforeDate) setBestBeforeDate(dayjs(bestMatch.bestBeforeDate));
            } else {
                if (!fromWarehouse && warehouses.length > 0) setFromWarehouse(warehouses[0].id);
                if (!selectedClient && clients.length > 0) setSelectedClient(clients[0].id);
            }
        } catch (e) {
            console.error("Auto-fill failed", e);
        }
        setTimeout(() => qtyRef.current?.focus(), 200);
    };


    const handleTransfer = async () => {
        if (!selectedProduct) return message.error("Please select a product");
        const prod = products.find((p) => Number(p.id) === Number(selectedProduct));
        if (!String(batchNumber || '').trim()) {
            return message.error(`${prod?.name || 'Product'} requires a Batch Number for this transfer.`);
        }
        if (!bestBeforeDate) {
            return message.error(`${prod?.name || 'Product'} requires a Best Before (Expiry) Date for this transfer.`);
        }
        if (!fromWarehouse) return message.error("Please select a source warehouse");
        if (!toWarehouse) return message.error("Please select a target warehouse");
        if (!fromLocation) return message.error("Please select source location");
        if (!toLocation) return message.error("Please select target location");
        if (fromWarehouse === toWarehouse && fromLocation === toLocation) return message.error("Source and target cannot be same");
        if (!selectedClient) return message.error("Please select a client");
        if (!qty || qty <= 0) return message.error("Please enter a valid quantity");
        const availableTotal = Math.round(Number(currentStock) || 0);
        if (availableTotal < qty) return message.error(`Insufficient stock in source location. Available: ${availableTotal}`);

        setProcessing(true);
        try {
            await apiRequest('/api/inventory/transfer-stock', {
                method: 'POST',
                body: JSON.stringify({
                    productId: selectedProduct,
                    fromWarehouseId: fromWarehouse,
                    toWarehouseId: toWarehouse,
                    fromLocationId: fromLocation,
                    toLocationId: toLocation,
                    clientId: selectedClient,
                    quantity: qty,
                    batchNumber,
                    bestBeforeDate: bestBeforeDate ? bestBeforeDate.format('YYYY-MM-DD') : null,
                    reason: reason || 'Internal Transfer',
                    userId: user?.id
                })
            }, token);

            message.success(`Quantity successfully moved`);
            setQty(1);
            setReason('');
            fetchCurrentStock();
            fetchHistory();
            setTimeout(() => barcodeRef.current?.focus(), 100);
        } catch (err) {
            message.error(err.message || "Transfer failed");
        } finally {
            setProcessing(false);
        }
    };

    const fromLocations = fromWarehouse
        ? locations.filter(l => {
            const whId = l.warehouseId || l.Warehouse?.id || l.Zone?.warehouseId || l.Zone?.Warehouse?.id;
            const isMatch = String(whId) === String(fromWarehouse);
            if (!isMatch) return false;
            // Additional check: If product is selected, prioritize bins with stock
            if (selectedProduct) {
                return stockBreakdown.some(s => s.locationId === l.id && s.quantity > 0);
            }
            return true;
        })
        : [];


    const toLocations = toWarehouse
        ? locations.filter(l => {
            const whId = l.warehouseId || l.Warehouse?.id || l.Zone?.warehouseId || l.Zone?.Warehouse?.id;
            return String(whId) === String(toWarehouse);
        })
        : [];


    const prodOptions = products.map(p => ({
        value: p.id,
        label: `[${p.sku || 'N/A'}] - ${p.name || 'Unnamed Product'}`
    }));

    const parseTransferRef = (referenceId) => {
        const m = String(referenceId || '').match(/TRANSFER:\s*(\d+):(\d+)\s*->\s*(\d+):(\d+)/i);
        if (!m) return null;
        return {
            fromWarehouseId: Number(m[1]),
            fromLocationId: Number(m[2]),
            toWarehouseId: Number(m[3]),
            toLocationId: Number(m[4]),
        };
    };


    return (
        <MainLayout>
            <div className="grid grid-cols-1 lg:grid-cols-12 gap-8 max-w-[1800px] mx-auto mt-2 pb-10 px-4">

                {/* LEFT COLUMN — Action Form */}
                <div className={`${historyCollapsed ? 'lg:col-span-12' : 'lg:col-span-7'} space-y-6`}>

                    {/* Header Card */}
                    <div className="bg-slate-900 rounded-3xl p-6 text-white shadow-2xl border border-slate-800 relative overflow-hidden group">
                        <div className="absolute top-0 right-0 p-4 opacity-10 group-hover:opacity-20 transition-all rotate-12">
                            <SwapOutlined className="text-8xl" />
                        </div>
                        <div className="relative z-10 flex items-center justify-between">
                            <div className="flex items-center gap-4">
                                <div className="w-14 h-14 bg-indigo-500 rounded-2xl flex items-center justify-center border border-indigo-400 shadow-inner">
                                    <SwapOutlined className="text-3xl text-white" />
                                </div>
                                <div>
                                    <h1 className="text-2xl font-black tracking-tight italic uppercase leading-none">Transfer Inventory</h1>
                                    <p className="text-slate-400 text-[10px] font-bold uppercase tracking-[0.3em] mt-1.5 flex items-center gap-2">
                                        <span className="w-1.5 h-1.5 rounded-full bg-emerald-500 animate-pulse"></span>
                                        Bin To Bin Stock Movement
                                    </p>
                                </div>
                            </div>
                            {historyCollapsed && (
                                <Button ghost className="border-slate-700 hover:border-slate-500 text-slate-300" icon={<ArrowRightOutlined className="rotate-180" />} onClick={() => setHistoryCollapsed(false)}>SHOW HISTORY</Button>
                            )}
                        </div>
                    </div>

                    <Card className="rounded-3xl shadow-sm border-gray-100" styles={{ body: { padding: 24 } }}>
                        <div className="space-y-5">

                            <div>
                                <label className="text-[10px] font-black text-slate-400 uppercase tracking-[0.2em] block mb-2">
                                    <div className="flex items-center gap-2">
                                        <div className="w-2 h-2 rounded-full bg-indigo-500 animate-pulse"></div>
                                        Quick Scan / Barcode
                                    </div>
                                </label>
                                <Input
                                    ref={barcodeRef}
                                    value={barcodeInput}
                                    onChange={e => setBarcodeInput(e.target.value)}
                                    onKeyDown={handleBarcodeKeyDown}
                                    placeholder="Scan or type barcode/SKU..."
                                    size="large"
                                    allowClear
                                    prefix={<ScanOutlined className="text-indigo-500 animate-pulse" />}
                                    className="rounded-xl border-dashed hover:border-indigo-500 focus:border-indigo-500 transition-all font-mono"
                                />
                                <p className="text-[10px] text-slate-400 mt-1.5 italic font-medium">Auto-identifies as you type • Enter to force search</p>
                            </div>

                            {/* Dropdowns Group */}
                            <div className="space-y-4">
                                <div className="grid grid-cols-3 gap-3">
                                    <div className="col-span-2">
                                        <label className="text-[11px] font-black text-slate-500 uppercase tracking-widest block mb-1.5 ml-1">Product (SKU | Name)</label>
                                        <Select
                                            showSearch
                                            optionFilterProp="label"
                                            placeholder="Search by SKU or Product Name..."
                                            className="w-full"
                                            size="large"
                                            allowClear
                                            dropdownMatchSelectWidth={false}
                                            value={selectedProduct}
                                            onChange={handleProductSelect}
                                            options={prodOptions}
                                        />
                                    </div>
                                    <div>
                                        <label className="text-[11px] font-black text-slate-500 uppercase tracking-widest block mb-1.5 ml-1">Source Warehouse</label>
                                        <Select
                                            placeholder="Pick WH"
                                            className="w-full"
                                            size="large"
                                            allowClear
                                            value={fromWarehouse}
                                            onChange={(v) => { setFromWarehouse(v); setFromLocation(null); }}
                                            options={warehouses.map(w => ({ value: w.id, label: w.name }))}
                                        />
                                    </div>
                                </div>

                                {selectedProduct && (
                                    <div className="bg-white border border-slate-100 rounded-xl overflow-hidden">
                                        <div className="px-3 py-1.5 bg-slate-50 border-b border-slate-100 flex justify-between items-center">
                                            <span className="text-[8px] font-black text-slate-400 uppercase tracking-widest">Current Product Locations</span>
                                            {loadingBreakdown && <Spin size="small" />}
                                        </div>
                                        <div className="max-h-[150px] overflow-y-auto custom-scrollbar">
                                            {stockBreakdown.filter((s) => (Number(s.quantity) || 0) > 0).length === 0 ? (
                                                <p className="p-4 text-[9px] text-slate-300 italic text-center">No source stock found for this SKU.</p>
                                            ) : (
                                                <div className="divide-y divide-slate-50">
                                                    {stockBreakdown
                                                        .filter((s) => (Number(s.quantity) || 0) > 0)
                                                        .slice(0, 60)
                                                        .map((s, idx) => (
                                                            <div
                                                                key={idx}
                                                                onClick={() => {
                                                                    setFromWarehouse(s.warehouseId || s.Warehouse?.id || null);
                                                                    setFromLocation(s.locationId || null);
                                                                    setSelectedClient(s.clientId || null);
                                                                    setBatchNumber(s.batchNumber || '');
                                                                    setBestBeforeDate(s.bestBeforeDate ? dayjs(s.bestBeforeDate) : null);
                                                                }}
                                                                className="flex items-center justify-between px-3 py-2 cursor-pointer transition-all hover:bg-indigo-50"
                                                            >
                                                                <div className="flex flex-col">
                                                                    <span className="text-[10px] font-bold text-slate-700">
                                                                        {(s.Warehouse?.name || '—')} / {(s.Location?.name || s.Location?.code || '—')}
                                                                    </span>
                                                                    <span className="text-[8px] text-slate-400">
                                                                        Batch: {s.batchNumber || 'N/A'} | Exp: {s.bestBeforeDate ? dayjs(s.bestBeforeDate).format('DD/MM/YY') : 'N/A'}
                                                                    </span>
                                                                </div>
                                                                <span className="text-[11px] font-black text-indigo-600">{formatQuantity(s.quantity)}</span>
                                                            </div>
                                                        ))}
                                                </div>
                                            )}
                                        </div>
                                    </div>
                                )}

                                <div className="grid grid-cols-2 gap-3">
                                    <div>
                                        <label className="text-[11px] font-black text-slate-500 uppercase tracking-widest block mb-1.5 ml-1">Client</label>
                                        <Select
                                            placeholder="Client"
                                            className="w-full" size="large"
                                            allowClear
                                            value={selectedClient}
                                            onChange={setSelectedClient}
                                            options={clients.map(c => ({ value: c.id, label: c.name }))}
                                        />
                                    </div>
                                    <div>
                                        <label className="text-[11px] font-black text-slate-500 uppercase tracking-widest block mb-1.5 ml-1">Quantity</label>
                                        <InputNumber
                                            ref={qtyRef}
                                            min={1}
                                            value={qty}
                                            onChange={setQty}
                                            className="w-full rounded-xl"
                                            size="large"
                                            placeholder="Amount..."
                                        />
                                    </div>
                                </div>

                                <div className="grid grid-cols-2 gap-3">
                                    <div>
                                        <label className="text-[11px] font-black text-slate-500 uppercase tracking-widest block mb-1.5 ml-1">Batch Number <span className="text-rose-500">*</span></label>
                                        <Input
                                            placeholder="Batch ID"
                                            className="w-full rounded-xl" size="large"
                                            value={batchNumber}
                                            onChange={e => setBatchNumber(e.target.value)}
                                        />
                                    </div>
                                    <div>
                                        <label className="text-[11px] font-black text-slate-500 uppercase tracking-widest block mb-1.5 ml-1">Expiry Date <span className="text-rose-500">*</span></label>
                                        <DatePicker
                                            className="w-full rounded-xl" size="large"
                                            format="DD/MM/YYYY"
                                            value={bestBeforeDate}
                                            onChange={setBestBeforeDate}
                                        />
                                    </div>
                                </div>

                                <div className="p-4 bg-slate-50 border border-slate-100 rounded-2xl space-y-4">
                                    {/* SOURCE SECTION */}
                                    <div className="space-y-3">
                                        <div className="flex items-center gap-2 mb-1">
                                            <div className="px-2 py-0.5 bg-red-100 text-red-700 text-[9px] font-black rounded uppercase">Source</div>
                                            <div className="h-px flex-1 bg-slate-200"></div>
                                        </div>
                                        <div className="grid grid-cols-2 gap-2">
                                            <Select
                                                placeholder="From WH"
                                                className="w-full" size="large"
                                                allowClear
                                                value={fromWarehouse}
                                                onChange={(v) => { setFromWarehouse(v); setFromLocation(null); }}
                                                options={warehouses.map(w => ({ value: w.id, label: w.name }))}
                                            />
                                            <Select
                                                showSearch optionFilterProp="label"
                                                placeholder="From Bin"
                                                className="w-full" size="large"
                                                allowClear
                                                disabled={!fromWarehouse}
                                                value={fromLocation}
                                                onChange={setFromLocation}
                                                options={fromLocations.length > 0
                                                    ? fromLocations.map(l => ({ value: l.id, label: l.name || l.code }))
                                                    : [{ value: null, label: selectedProduct ? 'No bins with stock found' : 'No bins found in warehouse', disabled: true }]}
                                            />
                                        </div>

                                        {/* Stock Breakdown */}
                                        {selectedProduct && fromWarehouse && (
                                            <div className="bg-white border border-slate-100 rounded-xl overflow-hidden">
                                                <div className="px-3 py-1.5 bg-slate-50 border-b border-slate-100 flex justify-between items-center">
                                                    <span className="text-[8px] font-black text-slate-400 uppercase tracking-widest">Available in this WH</span>
                                                    {loadingBreakdown && <Spin size="small" />}
                                                </div>
                                                <div className="max-h-[120px] overflow-y-auto custom-scrollbar">
                                                    {stockBreakdown.length === 0 ? <p className="p-4 text-[9px] text-slate-300 italic text-center">No stock records found.</p> : (
                                                        <div className="divide-y divide-slate-50">
                                                            {stockBreakdown.map((s, idx) => (
                                                                <div
                                                                    key={idx}
                                                                    onClick={() => { 
                                                                        setFromLocation(s.locationId); 
                                                                        setBatchNumber(s.batchNumber || ''); 
                                                                        setBestBeforeDate(s.bestBeforeDate ? dayjs(s.bestBeforeDate) : null);
                                                                    }}
                                                                    className={`flex items-center justify-between px-3 py-2 cursor-pointer transition-all ${fromLocation === s.locationId ? 'bg-indigo-50 border-l-4 border-l-indigo-500' : 'hover:bg-slate-50'}`}
                                                                >
                                                                    <div className="flex flex-col">
                                                                        <span className="text-[10px] font-bold text-slate-700">{s.Location?.name || s.Location?.code}</span>
                                                                        <span className="text-[8px] text-slate-400">Batch: {s.batchNumber || 'N/A'}</span>
                                                                    </div>
                                                                    <div className="text-right">
                                                                        <span className="text-[11px] font-black text-indigo-600">{formatQuantity(s.quantity)}</span>
                                                                    </div>
                                                                </div>
                                                            ))}
                                                        </div>
                                                    )}
                                                </div>
                                            </div>
                                        )}
                                    </div>

                                    {/* ARROW DIVIDER */}
                                    <div className="flex justify-center -my-3 isolate">
                                        <div className="w-8 h-8 rounded-full bg-white shadow-md flex items-center justify-center border border-slate-100 z-10">
                                            <ArrowRightOutlined className="text-indigo-500 rotate-90" />
                                        </div>
                                    </div>

                                    {/* TARGET SECTION */}
                                    <div className="space-y-3">
                                        <div className="flex items-center gap-2 mb-1">
                                            <div className="px-2 py-0.5 bg-emerald-100 text-emerald-700 text-[9px] font-black rounded uppercase">Destination</div>
                                            <div className="h-px flex-1 bg-slate-200"></div>
                                        </div>
                                        <div className="grid grid-cols-2 gap-2">
                                            <Select
                                                placeholder="To WH"
                                                className="w-full" size="large"
                                                allowClear
                                                value={toWarehouse}
                                                onChange={(v) => { setToWarehouse(v); setToLocation(null); }}
                                                options={warehouses.map(w => ({ value: w.id, label: w.name }))}
                                            />
                                            <Select
                                                showSearch optionFilterProp="label"
                                                placeholder="To Bin"
                                                className="w-full" size="large"
                                                allowClear
                                                disabled={!toWarehouse}
                                                value={toLocation}
                                                onChange={setToLocation}
                                                options={toLocations.length > 0
                                                    ? toLocations.map(l => ({ value: l.id, label: l.name || l.code }))
                                                    : [{ value: null, label: 'No bins found in destination warehouse', disabled: true }]}
                                            />
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <Tooltip title={
                                !selectedProduct ? "Please select a product first" :
                                    !fromLocation ? "Select source bin (From Bin)" :
                                        !toLocation ? "Select destination bin (To Bin)" :
                                            !selectedClient ? "Select a client" :
                                                currentStock < qty ? "Insufficient stock at source" :
                                                    ""
                            }>
                                <div className="w-full">
                                    <Button
                                        type="primary"
                                        size="large"
                                        icon={<SwapOutlined />}
                                        loading={processing}
                                        onClick={handleTransfer}
                                        disabled={!selectedProduct || !fromLocation || !toLocation || !selectedClient || !canCreate(user?.role) || (Math.round(Number(currentStock)) < qty)}
                                        className="w-full h-14 rounded-2xl bg-indigo-600 hover:bg-indigo-700 border-none font-black uppercase italic shadow-lg shadow-indigo-200 mt-2 flex items-center justify-center gap-2"
                                    >
                                        Move Stock Now
                                        {currentStock !== null && (
                                            <span className={`px-2 py-0.5 rounded-full text-[10px] font-bold ${currentStock < qty ? 'bg-rose-100 text-rose-600' : 'bg-white/20'}`}>
                                                {currentStock < qty ? `ONLY ${formatQuantity(currentStock)} LEFT` : `BAL: ${formatQuantity(currentStock)}`}
                                            </span>
                                        )}
                                    </Button>
                                </div>
                            </Tooltip>



                            {/* Optional Details Hidden per user request */}
                        </div>
                    </Card>
                </div>

                {/* RIGHT COLUMN — Transfer History (Collapsible) */}
                {!historyCollapsed && (
                    <div className="lg:col-span-5 min-w-0 animate-in slide-in-from-right duration-300">
                        <Card
                            className="rounded-2xl shadow-sm h-full border-gray-100 overflow-hidden flex flex-col"
                            title={
                                <div className="flex items-center justify-between py-1">
                                    <div className="flex items-center gap-2">
                                        <div className="h-4 w-1 bg-indigo-600 rounded-full"></div>
                                        <span className="font-black text-slate-800 uppercase tracking-tighter italic">History</span>
                                    </div>
                                    <Space>
                                        <Button size="small" shape="circle" icon={<ReloadOutlined />} onClick={fetchHistory} loading={loadingHistory} />
                                        <Button size="small" shape="circle" icon={<ArrowRightOutlined />} onClick={() => setHistoryCollapsed(true)} />
                                    </Space>
                                </div>
                            }
                            styles={{ body: { padding: 0, flex: 1 } }}
                        >
                            {loadingHistory ? (
                                <div className="flex flex-col items-center justify-center py-24 gap-4 opacity-40">
                                    <Spin size="large" />
                                    <span className="text-[10px] font-black uppercase tracking-widest text-slate-400">Syncing...</span>
                                </div>
                            ) : history.length === 0 ? (
                                <div className="py-24 text-center">
                                    <Empty image={Empty.PRESENTED_IMAGE_SIMPLE} description={<span className="text-slate-400 font-bold italic">No transfers recorded</span>} />
                                </div>
                            ) : (
                                <div className="divide-y divide-slate-100 max-h-[calc(100vh-200px)] overflow-y-auto custom-scrollbar">
                                    {history.map((entry, idx) => {
                                        const prod = entry.Product || entry.product || products.find((p) => Number(p.id) === Number(entry.productId)) || {};
                                        const dateStr = dayjs(entry.createdAt).format('DD MMM, HH:mm');
                                        const parsedRef = parseTransferRef(entry.referenceId);
                                        const ref = {
                                            ...(parsedRef || {}),
                                            fromWarehouseId: entry.fromWarehouseId || parsedRef?.fromWarehouseId,
                                            fromLocationId: entry.fromLocationId || parsedRef?.fromLocationId,
                                            toWarehouseId: entry.toWarehouseId || parsedRef?.toWarehouseId,
                                            toLocationId: entry.toLocationId || parsedRef?.toLocationId,
                                        };
                                        const hasFullRoute =
                                            Number.isFinite(Number(ref?.fromWarehouseId)) &&
                                            Number.isFinite(Number(ref?.fromLocationId)) &&
                                            Number.isFinite(Number(ref?.toWarehouseId)) &&
                                            Number.isFinite(Number(ref?.toLocationId));
                                        const fromWh = warehouses.find((w) => Number(w.id) === Number(ref?.fromWarehouseId));
                                        const toWh = warehouses.find((w) => Number(w.id) === Number(ref?.toWarehouseId));
                                        const fromLoc = locations.find((l) => Number(l.id) === Number(ref?.fromLocationId));
                                        const toLoc = locations.find((l) => Number(l.id) === Number(ref?.toLocationId));
                                        return (
                                            <div key={entry.id || idx} className="flex items-center gap-4 px-6 py-5 hover:bg-slate-50 transition-all group border-l-4 border-l-transparent hover:border-l-indigo-500">
                                                <div className="w-10 h-10 rounded-xl bg-slate-50 flex items-center justify-center shrink-0 border border-slate-100 text-slate-400 group-hover:text-indigo-600 group-hover:bg-indigo-50 transition-colors">
                                                    <SwapOutlined className="text-lg" />
                                                </div>
                                                <div className="flex-1 min-w-0">
                                                    <div className="flex items-center justify-between mb-1 gap-2">
                                                        <p className="font-black text-slate-900 text-[14px] leading-tight truncate tracking-tight">
                                                            <span className="text-indigo-600 mr-1.5">[{prod.sku || 'N/A'}]</span>
                                                            {prod.name || `Internal Move #${entry.productId || 'N/A'}`}
                                                        </p>
                                                        <span className="text-[9px] text-slate-400 font-bold uppercase shrink-0 bg-slate-50 px-2 py-0.5 rounded-full">{dateStr}</span>
                                                    </div>
                                                    <div className="flex flex-wrap items-center gap-x-3 gap-y-1">
                                                        <span className="text-[10px] font-black text-indigo-600">Qty: {formatQuantity(Math.abs(entry.quantity))}</span>
                                                        {hasFullRoute ? (
                                                            <span className="text-[9px] text-slate-500 flex items-center gap-1">
                                                                <EnvironmentOutlined className="opacity-50" />
                                                                {(fromWh?.name || `WH-${ref.fromWarehouseId}`)} / {(fromLoc?.name || fromLoc?.code || `BIN-${ref.fromLocationId}`)}
                                                                {' -> '}
                                                                {(toWh?.name || `WH-${ref.toWarehouseId}`)} / {(toLoc?.name || toLoc?.code || `BIN-${ref.toLocationId}`)}
                                                            </span>
                                                        ) : (
                                                            <span className="text-[9px] text-slate-500 flex items-center gap-1">
                                                                <EnvironmentOutlined className="opacity-50" />
                                                                {entry.Warehouse?.name || 'WH'} / {entry.Location?.name || entry.locationName || 'Unassigned'}
                                                            </span>
                                                        )}
                                                        <span className="text-[9px] text-slate-500 flex items-center gap-1">
                                                            <TeamOutlined className="opacity-50" />
                                                            {entry.Client?.name || entry.clientId || 'KIAAN'}
                                                        </span>
                                                        {/* Added Batch/Exp Information to original UI style */}
                                                        <span className="text-[9px] text-slate-500 flex items-center gap-1">
                                                            <TagOutlined className="opacity-50" />
                                                            {entry.batchNumber || 'N/A'} | {entry.bestBeforeDate ? dayjs(entry.bestBeforeDate).format('DD/MM/YY') : 'N/A'}
                                                        </span>
                                                    </div>
                                                    <p className="text-[9px] text-slate-400 mt-2 font-medium italic opacity-70">
                                                        Reason: {entry.reason || 'Standard internal bin movement'}
                                                    </p>
                                                </div>
                                            </div>
                                        );
                                    })}
                                </div>
                            )}
                        </Card>
                    </div>
                )}
            </div>

            <style dangerouslySetInnerHTML={{
                __html: `
                .custom-scrollbar::-webkit-scrollbar { width: 5px; }
                .custom-scrollbar::-webkit-scrollbar-track { background: transparent; }
                .custom-scrollbar::-webkit-scrollbar-thumb { background: #e2e8f0; border-radius: 10px; }
                .custom-scrollbar::-webkit-scrollbar-thumb:hover { background: #cbd5e1; }
            `}} />
        </MainLayout>
    );
}
