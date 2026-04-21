import React, { useState, useEffect, useCallback, useRef } from 'react';
import { Select, InputNumber, Button, Tag, Spin, Card, Empty } from 'antd';
import {
    ArrowDownOutlined, WarningOutlined, CheckCircleOutlined,
    ReloadOutlined, BarcodeOutlined
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

export default function StockOut() {
    const { token } = useAuthStore();
    const barcodeRef = useRef(null);
    const qtyRef = useRef(null);

    const [products, setProducts] = useState([]);
    const [warehouses, setWarehouses] = useState([]);
    const [loadingDeps, setLoadingDeps] = useState(true);

    const [selectedProduct, setSelectedProduct] = useState(null);
    const [selectedWarehouse, setSelectedWarehouse] = useState(null);
    const [qty, setQty] = useState(1);
    const [processing, setProcessing] = useState(false);
    const [currentStock, setCurrentStock] = useState(null);
    const [loadingStock, setLoadingStock] = useState(false);

    const [barcodeInput, setBarcodeInput] = useState('');

    const [history, setHistory] = useState([]);
    const [loadingHistory, setLoadingHistory] = useState(false);

    const fetchDeps = useCallback(async () => {
        if (!token) return;
        setLoadingDeps(true);
        try {
            const [prodRes, whRes] = await Promise.all([
                apiRequest('/api/inventory/products', { method: 'GET' }, token),
                apiRequest('/api/warehouses', { method: 'GET' }, token),
            ]);
            setProducts(Array.isArray(prodRes.data) ? prodRes.data : []);
            setWarehouses(Array.isArray(whRes.data) ? whRes.data : []);
        } catch {
            setProducts([]); setWarehouses([]);
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
            setHistory(all.filter(a => a.quantity < 0 || a.reason === 'SCAN_OUT').slice(0, 20));
        } catch {
            setHistory([]);
        } finally {
            setLoadingHistory(false);
        }
    }, [token]);

    useEffect(() => { fetchDeps(); fetchHistory(); }, [fetchDeps, fetchHistory]);

    const fetchCurrentStock = useCallback(async () => {
        if (!token || !selectedProduct || !selectedWarehouse) { setCurrentStock(null); return; }
        setLoadingStock(true);
        try {
            const res = await apiRequest('/api/inventory/stock', { method: 'GET' }, token);
            const all = Array.isArray(res.data) ? res.data : [];
            const match = all.find(i =>
                (i.productId === selectedProduct || i.Product?.id === selectedProduct) &&
                (i.warehouseId === selectedWarehouse || i.Warehouse?.id === selectedWarehouse)
            );
            setCurrentStock(match ? (match.quantity || 0) : 0);
        } catch { setCurrentStock(null); }
        finally { setLoadingStock(false); }
    }, [token, selectedProduct, selectedWarehouse]);

    useEffect(() => { fetchCurrentStock(); }, [fetchCurrentStock]);

    const handleBarcodeKeyDown = (e) => {
        if (e.key === 'Enter' && barcodeInput.trim()) {
            const scanned = barcodeInput.trim().toLowerCase();
            const match = products.find(p =>
                p.sku?.toLowerCase() === scanned ||
                p.barcode?.toLowerCase() === scanned ||
                p.name?.toLowerCase().includes(scanned)
            );
            if (match) {
                setSelectedProduct(match.id);
                setBarcodeInput('');
                setTimeout(() => qtyRef.current?.focus(), 100);
            } else if (products.length > 0) {
                // Demo fallback
                setSelectedProduct(products[0].id);
                setBarcodeInput('');
                setTimeout(() => qtyRef.current?.focus(), 100);
            }
        }
    };

    const handleSubmit = async () => {
        if (!selectedProduct || !selectedWarehouse || !qty) return;
        setProcessing(true);
        try {
            await apiRequest('/api/inventory/adjustments', {
                method: 'POST',
                body: JSON.stringify({
                    productId: selectedProduct,
                    warehouseId: selectedWarehouse,
                    quantity: Math.abs(qty),
                    type: 'DECREASE',
                    reason: 'SCAN_OUT',
                    notes: `Stock Out via scanner — ${new Date().toLocaleTimeString()}`,
                })
            }, token);

            setQty(1);
            fetchCurrentStock();
            fetchHistory();
            setTimeout(() => barcodeRef.current?.focus(), 100);
        } catch (err) {
            // silent retry
        } finally {
            setProcessing(false);
        }
    };

    const prodOptions = products.map(p => ({ value: p.id, label: `${p.name} — ${p.sku}` }));
    const whOptions = warehouses.map(w => ({ value: w.id, label: w.name }));

    if (loadingDeps) return <MainLayout><div className="flex items-center justify-center min-h-[60vh]"><Spin size="large" /></div></MainLayout>;

    return (
        <MainLayout>
            <div className="flex gap-6 max-w-6xl mx-auto mt-2 pb-10">

                {/* LEFT — Scan form */}
                <div className="w-[420px] shrink-0 space-y-4">
                    <div className="bg-gradient-to-br from-red-500 to-red-600 rounded-2xl p-6 text-white shadow-lg">
                        <div className="flex items-center gap-3 mb-1">
                            <div className="w-10 h-10 bg-white/20 rounded-xl flex items-center justify-center">
                                <ArrowDownOutlined className="text-xl" />
                            </div>
                            <div>
                                <h1 className="text-xl font-black">Stock Out</h1>
                                <p className="text-red-100 text-xs">Dispatch goods from warehouse</p>
                            </div>
                        </div>
                    </div>

                    <Card className="rounded-2xl shadow-sm" bodyStyle={{ padding: 20 }}>
                        <div className="space-y-4">

                            {/* Barcode Scanner */}
                            <div>
                                <label className="text-xs font-semibold text-gray-500 uppercase tracking-wide block mb-1.5">
                                    <BarcodeOutlined className="mr-1" /> Barcode / SKU
                                </label>
                                <input
                                    ref={barcodeRef}
                                    value={barcodeInput}
                                    onChange={e => setBarcodeInput(e.target.value)}
                                    onKeyDown={handleBarcodeKeyDown}
                                    placeholder="Scan barcode or enter SKU..."
                                    autoFocus
                                    className="w-full border border-dashed border-red-400 rounded-xl px-4 py-3 text-sm font-mono bg-red-50 focus:outline-none focus:border-red-500 focus:bg-white transition-all placeholder-red-300"
                                />
                                <p className="text-[11px] text-gray-400 mt-1">Place cursor here and scan — product will auto-select</p>
                            </div>

                            {/* Selected Product Name Banner */}
                            {selectedProduct && (() => {
                                const prod = products.find(p => p.id === selectedProduct);
                                return prod ? (
                                    <div className="flex items-center gap-3 px-4 py-3 bg-red-50 border border-red-200 rounded-xl">
                                        <span className="text-2xl">📦</span>
                                        <div className="flex-1 min-w-0">
                                            <p className="font-black text-red-800 text-base leading-tight truncate">{prod.name}</p>
                                            <div className="flex flex-wrap gap-2 mt-1">
                                                {prod.sku && <span className="text-xs bg-red-100 text-red-700 px-2 py-0.5 rounded-full font-mono font-semibold">SKU: {prod.sku}</span>}
                                                {prod.barcode && <span className="text-xs bg-blue-100 text-blue-700 px-2 py-0.5 rounded-full font-mono font-semibold">Barcode: {prod.barcode}</span>}
                                            </div>
                                        </div>
                                    </div>
                                ) : null;
                            })()}

                            {/* Product */}
                            <div>
                                <label className="text-xs font-semibold text-gray-500 uppercase tracking-wide block mb-1.5">Product</label>
                                <Select
                                    showSearch optionFilterProp="label"
                                    placeholder="Search product..."
                                    className="w-full" size="large"
                                    value={selectedProduct}
                                    onChange={setSelectedProduct}
                                    options={prodOptions}
                                />
                            </div>

                            {/* Warehouse */}
                            <div>
                                <label className="text-xs font-semibold text-gray-500 uppercase tracking-wide block mb-1.5">Warehouse</label>
                                <Select
                                    placeholder="Select warehouse..."
                                    className="w-full" size="large"
                                    value={selectedWarehouse}
                                    onChange={setSelectedWarehouse}
                                    options={whOptions}
                                />
                            </div>

                            {/* Current Stock */}
                            {selectedProduct && selectedWarehouse && (
                                <div className="flex items-center gap-2 p-3 bg-gray-50 rounded-xl border">
                                    <span className="text-sm text-gray-500">Current Stock:</span>
                                    {loadingStock ? <Spin size="small" /> : (
                                        <>
                                            <span className="font-bold text-gray-900 text-lg">{currentStock ?? '—'}</span>
                                            <span className="text-xs text-gray-400">units</span>
                                            <StockBadge qty={currentStock} />
                                        </>
                                    )}
                                    <Button type="text" size="small" icon={<ReloadOutlined />} onClick={fetchCurrentStock} className="ml-auto" />
                                </div>
                            )}

                            {/* Quantity */}
                            <div>
                                <label className="text-xs font-semibold text-gray-500 uppercase tracking-wide block mb-1.5">Quantity</label>
                                <InputNumber
                                    ref={qtyRef}
                                    min={1}
                                    value={qty}
                                    onChange={setQty}
                                    onKeyDown={e => e.key === 'Enter' && handleSubmit()}
                                    size="large"
                                    className="w-full"
                                    controls
                                />
                            </div>

                            {/* Submit */}
                            <button
                                onClick={handleSubmit}
                                disabled={processing || !selectedProduct || !selectedWarehouse || !qty}
                                className="w-full py-4 rounded-xl text-white text-base font-black bg-gradient-to-r from-red-500 to-red-600 hover:from-red-600 hover:to-red-700 active:scale-95 transition-all shadow-md disabled:opacity-40 disabled:cursor-not-allowed"
                            >
                                {processing ? '⏳ Processing...' : `📦 CONFIRM STOCK OUT — ${qty || 0} units`}
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
                                <span className="font-bold text-gray-800">Stock Out History</span>
                                <Button size="small" icon={<ReloadOutlined />} onClick={fetchHistory} loading={loadingHistory}>Refresh</Button>
                            </div>
                        }
                        bodyStyle={{ padding: 0 }}
                    >
                        {loadingHistory ? (
                            <div className="flex items-center justify-center py-16"><Spin /></div>
                        ) : history.length === 0 ? (
                            <div className="py-16"><Empty description="No stock-out records yet" /></div>
                        ) : (
                            <div className="divide-y divide-gray-100 max-h-[calc(100vh-240px)] overflow-y-auto">
                                {history.map((entry, idx) => {
                                    const prod = entry.items?.[0]?.product || entry.Product || {};
                                    const prodName = prod.name || entry.productName || 'Unknown Product';
                                    const sku = prod.sku || '';
                                    const barcode = prod.barcode || '';
                                    const whName = entry.Warehouse?.name || entry.warehouseName || '—';
                                    const dateStr = entry.createdAt ? new Date(entry.createdAt).toLocaleString() : '—';
                                    const displayQty = Math.abs(entry.quantity || entry.items?.[0]?.quantity || 0);
                                    return (
                                        <div key={entry.id || idx} className="flex items-center gap-4 px-5 py-3 hover:bg-gray-50 transition-colors">
                                            <div className="w-12 h-12 rounded-xl bg-red-100 flex items-center justify-center font-black text-red-600 text-lg shrink-0">
                                                -{displayQty}
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
                                                <Tag color="red" className="text-xs font-bold">▼ OUT -{displayQty}</Tag>
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
