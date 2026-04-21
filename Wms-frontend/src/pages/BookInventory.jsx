import React, { useState, useEffect, useCallback, useRef } from 'react';
import { Select, InputNumber, Button, Tag, Spin, Card, Empty, Tooltip, DatePicker, Divider, Input, App, Space } from 'antd';
import {
    ArrowUpOutlined, ArrowDownOutlined, CheckCircleOutlined, WarningOutlined,
    ReloadOutlined, BarcodeOutlined, ScanOutlined, SolutionOutlined,
    EnvironmentOutlined, TeamOutlined, TagOutlined,
    FileTextOutlined, ArrowRightOutlined, ArrowLeftOutlined
} from '@ant-design/icons';
import dayjs from 'dayjs';
import { MainLayout } from '../components/layout/MainLayout';
import { useAuthStore } from '../store/authStore';
import { canCreate, canUpdate, isAdmin } from '../permissions';
import { apiRequest } from '../api/client';
import { formatQuantity } from '../utils';

function StockBadge({ qty }) {
    if (qty === null || qty === undefined) return null;
    if (qty <= 0) return <Tag color="red" icon={<WarningOutlined />}>Out of Stock</Tag>;
    if (qty <= 50) return <Tag color="orange" icon={<WarningOutlined />}>Low Stock</Tag>;
    return <Tag color="green" icon={<CheckCircleOutlined />}>In Stock</Tag>;
}

const BookInventory = () => {
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
    const [selectedWarehouse, setSelectedWarehouse] = useState(null);
    const [selectedLocation, setSelectedLocation] = useState(null);
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
    const [activeTab, setActiveTab] = useState('inventory');
    const [orderAllocations, setOrderAllocations] = useState([]);
    const [loadingAllocations, setLoadingAllocations] = useState(false);
    const isTruthyYes = (value) => ['yes', 'true'].includes(String(value || '').toLowerCase());
    const isSameClient = (rowClientId, selectedId) => {
        if (!selectedId) return true;
        return String(rowClientId ?? '') === String(selectedId);
    };



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
            const res = await apiRequest('/api/inventory/logs?limit=50', { method: 'GET' }, token);
            setHistory(Array.isArray(res.data) ? res.data : []);
        } catch {
            setHistory([]);
        } finally {
            setLoadingHistory(false);
        }
    }, [token]);


    const fetchCurrentStock = useCallback(async () => {
        if (!token || !selectedProduct || !selectedWarehouse) { setCurrentStock(null); return; }
        setLoadingStock(true);
        try {
            const res = await apiRequest('/api/inventory/stock', { method: 'GET' }, token);
            const all = Array.isArray(res.data) ? res.data : [];
            const matches = all.filter(i =>
                (i.productId === selectedProduct || i.Product?.id === selectedProduct) &&
                (i.warehouseId === selectedWarehouse || i.Warehouse?.id === selectedWarehouse) &&
                (!selectedLocation || i.locationId === selectedLocation) &&
                isSameClient(i.clientId || i.Client?.id, selectedClient)
            );
            const total = matches.reduce((sum, row) => sum + (Number(row.quantity) || 0), 0);
            setCurrentStock(total);
        } catch { setCurrentStock(null); }
        finally { setLoadingStock(false); }
    }, [token, selectedProduct, selectedWarehouse, selectedLocation, selectedClient]);

    const fetchStockBreakdown = useCallback(async () => {
        if (!token || !selectedProduct) { setStockBreakdown([]); return; }
        setLoadingBreakdown(true);
        try {
            // Fetch all stock for this product to show overview and breakdown
            const url = selectedWarehouse 
                ? `/api/inventory/stock?productId=${selectedProduct}&warehouseId=${selectedWarehouse}`
                : `/api/inventory/stock?productId=${selectedProduct}`;
            const res = await apiRequest(url, { method: 'GET' }, token);
            const rows = Array.isArray(res.data) ? res.data : [];
            setStockBreakdown(rows.filter((row) => isSameClient(row.clientId || row.Client?.id, selectedClient)));
        } catch { setStockBreakdown([]); }
        finally { setLoadingBreakdown(false); }
    }, [token, selectedProduct, selectedWarehouse, selectedClient]);

    const fetchOrderAllocations = useCallback(async () => {
        if (!token || !selectedProduct) { setOrderAllocations([]); return; }
        setLoadingAllocations(true);
        try {
            // Fetch active orders to see pending allocations (DRAFT, CONFIRMED, etc.)
            const res = await apiRequest('/api/orders/sales', { method: 'GET' }, token);
            const allOrders = Array.isArray(res.data) ? res.data : [];
            
            const allocations = [];
            allOrders.forEach(order => {
                // Skip finished or cancelled orders
                const status = (order.status || '').toUpperCase();
                if (['DELIVERED', 'SHIPPED', 'CANCELLED', 'RETURNED'].includes(status)) return;

                // Support various possible backend keys for OrderItems association
                const items = order.OrderItems || order.order_items || order.orderItems || [];
                const item = items.find(oi => Number(oi.productId) === Number(selectedProduct));

                const orderClientId = order.customerId || order.clientId || order.Customer?.id || order.Client?.id;
                if (item && isSameClient(orderClientId, selectedClient)) {
                    allocations.push({
                        orderNumber: order.orderNumber,
                        salesChannel: order.salesChannel || 'Direct',
                        status: order.status,
                        locationCode: 'Pending', 
                        quantity: Number(item.quantity) || 0,
                        bbd: '—',
                        batch: '—'
                    });
                }
            });
            setOrderAllocations(allocations);
        } catch (err) { 
            console.error("Allocations fetch error", err);
            setOrderAllocations([]); 
        } finally { setLoadingAllocations(false); }
    }, [token, selectedProduct, selectedClient]);

    useEffect(() => { fetchDeps(); fetchHistory(); }, [fetchDeps, fetchHistory]);
    useEffect(() => { fetchCurrentStock(); }, [fetchCurrentStock]);
    useEffect(() => { fetchStockBreakdown(); fetchOrderAllocations(); }, [fetchStockBreakdown, fetchOrderAllocations]);



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
        if (prod && prod.barcode) {
            setBarcodeInput(prod.barcode);
        }
        
        // AUTO-FILL LOGIC: Fetch where we have stock
        try {
            const res = await apiRequest(`/api/inventory/stock?productId=${prodId}`, { method: 'GET' }, token);
            const stocks = Array.isArray(res.data) ? res.data : [];
            
            if (stocks.length > 0) {
                // Pick the record with highest quantity as the default
                const bestMatch = [...stocks].sort((a,b) => b.quantity - a.quantity)[0];
                if (bestMatch.warehouseId) setSelectedWarehouse(bestMatch.warehouseId);
                if (bestMatch.locationId) setSelectedLocation(bestMatch.locationId);
                if (bestMatch.clientId) setSelectedClient(bestMatch.clientId);
            } else {
                // If no stock, pick defaults to help the user get started
                if (!selectedWarehouse && warehouses.length > 0) setSelectedWarehouse(warehouses[0].id);
                if (!selectedClient && clients.length > 0) setSelectedClient(clients[0].id);
            }

            // If we have a warehouse but no location selected yet, pick the first bin
            setTimeout(() => {
                const currentWH = selectedWarehouse || (warehouses.length > 0 ? warehouses[0].id : null);
                if (currentWH && !selectedLocation) {
                    const firstLoc = locations.find(l => {
                        const whId = l.warehouseId || l.Warehouse?.id || l.Zone?.warehouseId || l.Zone?.Warehouse?.id;
                        return Number(whId) === Number(currentWH);
                    });
                    if (firstLoc) setSelectedLocation(firstLoc.id);
                }
            }, 100);

        } catch (e) {
            console.error("Auto-fill failed", e);
        }
        
        setTimeout(() => qtyRef.current?.focus(), 200);
    };



    const handleAction = async (type) => {
        if (!selectedProduct) return message.error("Please select a product");
        const prod = products.find(p => p.id === selectedProduct);
        if (!batchNumber.trim()) {
            return message.error(`${prod?.name || 'Product'} requires a Batch Number for accurate tracking.`);
        }
        if (!bestBeforeDate) {
            return message.error(`${prod?.name || 'Product'} requires a Best Before (Expiry) Date.`);
        }

        if (!selectedWarehouse) return message.error("Please select a warehouse");
        if (!selectedLocation) return message.error("Please select a location");
        if (!selectedClient) return message.error("Please select a client");
        if (!qty || qty <= 0) return message.error("Please enter a valid quantity");


        setProcessing(true);
        try {
            await apiRequest('/api/inventory/adjustments', {
                method: 'POST',
                body: JSON.stringify({
                    productId: selectedProduct,
                    warehouseId: selectedWarehouse,
                    locationId: selectedLocation,
                    clientId: selectedClient,
                    quantity: Math.round(Math.abs(Number(qty) || 0)),
                    type: type, // INCREASE or DECREASE
                    batchNumber: batchNumber?.trim() || null,
                    bestBeforeDate: bestBeforeDate ? bestBeforeDate.format('YYYY-MM-DD') : null,
                    reason: reason || (type === 'INCREASE' ? 'Manual Stock In' : 'Manual Stock Out'),
                    userId: user?.id
                })
            }, token);

            message.success(`Inventory successfully updated (${type === 'INCREASE' ? 'IN' : 'OUT'})`);
            setQty(1);
            setBatchNumber('');
            setBestBeforeDate(null);
            setReason('');
            fetchCurrentStock();
            fetchStockBreakdown();
            fetchHistory();
            setTimeout(() => barcodeRef.current?.focus(), 100);
        } catch (err) {
            message.error(err.message || "Failed to update inventory");
        } finally {
            setProcessing(false);
        }
    };

    const filteredLocations = selectedWarehouse
        ? locations.filter((l) => {
            const whId = l.warehouseId || l.Warehouse?.id || l.Zone?.warehouseId || l.Zone?.Warehouse?.id;
            return String(whId || '') === String(selectedWarehouse || '');
        }).sort((a, b) => {
            // SMART SORTING: Put locations with current stock at the top
            const hasA = stockBreakdown.some(s => String(s.locationId) === String(a.id) && s.quantity > 0);
            const hasB = stockBreakdown.some(s => String(s.locationId) === String(b.id) && s.quantity > 0);
            if (hasA && !hasB) return -1;
            if (!hasA && hasB) return 1;
            return 0;
        })
        : [];


    const prodOptions = products
        .map((p) => ({
            value: p.id,
            label: `${p.sku || 'N/A'} | ${p.name || 'Unnamed Product'}`
        }));




    if (loadingDeps) return <MainLayout><div className="flex items-center justify-center min-h-[60vh]"><Spin size="large" /></div></MainLayout>;

    return (
        <MainLayout>
            <div className="grid grid-cols-1 lg:grid-cols-12 gap-8 max-w-[1800px] mx-auto mt-2 pb-10 px-4">
                
                {/* LEFT COLUMN — Main Workspace (Responsive Span) */}
                <div className={`${historyCollapsed ? 'lg:col-span-12' : 'lg:col-span-7'} space-y-6`}>

                    
                    {/* Header Card */}
                    <div className="bg-slate-900 rounded-3xl p-6 text-white shadow-2xl border border-slate-800 relative overflow-hidden group">
                        <div className="absolute top-0 right-0 p-4 opacity-10 group-hover:opacity-20 transition-all rotate-12">
                            <SolutionOutlined className="text-8xl" />
                        </div>
                        <div className="relative z-10 flex items-center gap-4">
                            <div className="w-14 h-14 bg-indigo-500 rounded-2xl flex items-center justify-center border border-indigo-400 shadow-inner">
                                <SolutionOutlined className="text-3xl text-white" />
                            </div>
                            <div>
                                <h1 className="text-2xl font-black tracking-tight italic uppercase leading-none">Book Inventory</h1>
                                <p className="text-slate-400 text-[10px] font-bold uppercase tracking-[0.3em] mt-1.5 flex items-center gap-2">
                                    <span className="w-1.5 h-1.5 rounded-full bg-emerald-500 animate-pulse"></span>
                                    Live Terminal System
                                </p>
                            </div>
                        </div>
                    </div>

                    <Card className="rounded-3xl shadow-sm border-gray-100" styles={{ body: { padding: 24 } }}>
                        <div className="space-y-5">
                            
                            <div>
                                <label className="text-[10px] font-black text-slate-400 uppercase tracking-[0.2em] block mb-2">
                                    <div className="flex items-center gap-2">
                                        <div className="w-2 h-2 rounded-full bg-blue-500 animate-pulse"></div>
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
                                    prefix={<ScanOutlined className="text-blue-500 animate-pulse" />}
                                    className="rounded-xl border-dashed hover:border-blue-500 focus:border-blue-500 transition-all font-mono"
                                />
                                <p className="text-[10px] text-slate-400 mt-1.5 italic font-medium">Auto-identifies as you type • Enter to force search</p>
                            </div>


                                <div className="space-y-6">
                                    <div className="grid grid-cols-1 xl:grid-cols-2 gap-4">
                                        <div className="flex items-center gap-4 min-w-0">
                                            <label className="text-[11px] font-black text-slate-500 uppercase tracking-widest w-24">Client</label>
                                            <Select
                                                placeholder="Pick Client"
                                                className="flex-1 min-w-0" size="large"
                                                allowClear
                                                value={selectedClient}
                                                onChange={setSelectedClient}
                                                options={clients.map(c => ({ value: c.id, label: c.name }))}
                                            />
                                        </div>
                                        <div className="flex items-center gap-4 min-w-0">
                                            <label className="text-[11px] font-black text-slate-500 uppercase tracking-widest w-24">Warehouse</label>
                                            <Select
                                                placeholder="Pick Warehouse"
                                                className="flex-1 min-w-0" size="large"
                                                allowClear
                                                value={selectedWarehouse}
                                                onChange={(v) => { setSelectedWarehouse(v); setSelectedLocation(null); }}
                                                options={warehouses.map(w => ({ value: w.id, label: w.name }))}
                                            />
                                        </div>
                                    </div>
                                    <div className="flex items-center gap-4 min-w-0">
                                        <label className="text-[11px] font-black text-slate-500 uppercase tracking-widest w-24">Product</label>
                                        <Select
                                            showSearch 
                                            optionFilterProp="label"
                                            placeholder="SKU | Product Name"
                                            className="flex-1 min-w-0" 
                                            size="large"
                                            allowClear
                                            dropdownMatchSelectWidth={false}
                                            listHeight={400}
                                            value={selectedProduct}
                                            onChange={handleProductSelect}
                                            options={prodOptions}
                                        />
                                    </div>

                                    {selectedProduct && (
                                        <>
                                            {/* 1. Inventory Summary Table */}
                                            <div className="mt-8">
                                                <h3 className="text-xl font-bold mb-3">Inventory</h3>
                                                <div className="border border-slate-200 rounded-lg overflow-hidden">
                                                    <table className="w-full text-[11px] text-center">
                                                        <thead className="bg-slate-50 border-b border-slate-200 font-bold">
                                                            <tr>
                                                                <th className="px-4 py-2 text-left border-r">Product SKU</th>
                                                                <th className="px-4 py-2 text-left border-r">Product</th>
                                                                <th className="px-4 py-2 border-r">Stock Level</th>
                                                                <th className="px-4 py-2 border-r">Allocated</th>
                                                                <th className="px-4 py-2 border-r">On hand</th>
                                                                <th className="px-4 py-2 border-r text-[9px] leading-tight">Required By<br/>Backorder</th>
                                                                <th className="px-4 py-2 text-left">Warehouse</th>
                                                            </tr>
                                                        </thead>
                                                        <tbody>
                                                            {(() => {
                                                                const prod = products.find(p => p.id === selectedProduct);
                                                                const stockLevel = stockBreakdown.reduce((sum, s) => sum + (Number(s.quantity) || 0), 0);
                                                                const allocated = orderAllocations.reduce((sum, a) => sum + (Number(a.quantity) || 0), 0);
                                                                const onHand = stockLevel - allocated;
                                                                const backorder = Math.max(0, allocated - stockLevel);
                                                                return (
                                                                    <tr className="border-b border-slate-100 italic font-medium">
                                                                        <td className="px-4 py-2.5 text-left border-r bg-slate-50/30">{prod?.sku || 'N/A'}</td>
                                                                        <td className="px-4 py-2.5 text-left border-r">{prod?.name || 'N/A'}</td>
                                                                        <td className="px-4 py-2.5 border-r font-bold">{formatQuantity(stockLevel)}</td>
                                                                        <td className="px-4 py-2.5 border-r text-rose-600">{formatQuantity(allocated)}</td>
                                                                        <td className="px-4 py-2.5 border-r font-black text-indigo-600">{formatQuantity(onHand)}</td>
                                                                        <td className="px-4 py-2.5 border-r text-orange-600">{formatQuantity(backorder)}</td>
                                                                        <td className="px-4 py-2.5 text-left font-bold">{warehouses.find(w => w.id === selectedWarehouse)?.name || 'Main Warehouse'}</td>
                                                                    </tr>
                                                                );
                                                            })()}
                                                        </tbody>
                                                    </table>
                                                </div>
                                            </div>

                                            {/* 2. Order Allocations Table */}
                                            <div className="mt-8">
                                                <h3 className="text-xl font-bold mb-3">Order Allocations</h3>
                                                <div className="border border-slate-200 rounded-lg overflow-hidden">
                                                    <table className="w-full text-[11px] text-center">
                                                        <thead className="bg-slate-50 border-b border-slate-200 font-bold">
                                                            <tr>
                                                                <th className="px-4 py-2 text-left border-r">Order Id</th>
                                                                <th className="px-4 py-2 text-left border-r">Sales Channel</th>
                                                                <th className="px-4 py-2 border-r">Order Status</th>
                                                                <th className="px-4 py-2 border-r">Location</th>
                                                                <th className="px-4 py-2 border-r">Quantity</th>
                                                                <th className="px-4 py-2 border-r">Best Before</th>
                                                                <th className="px-4 py-2">Batch No</th>
                                                            </tr>
                                                        </thead>
                                                        <tbody>
                                                            {orderAllocations.length === 0 ? (
                                                                <tr><td colSpan={7} className="py-4 text-slate-300 italic">No allocations found</td></tr>
                                                            ) : orderAllocations.map((a, i) => (
                                                                <tr key={i} className="border-b border-slate-100">
                                                                    <td className="px-4 py-2.5 text-left border-r underline text-blue-600 cursor-pointer">{a.orderNumber}</td>
                                                                    <td className="px-4 py-2.5 text-left border-r">{a.salesChannel}</td>
                                                                    <td className="px-4 py-2.5 border-r uppercase">{a.status}</td>
                                                                    <td className="px-4 py-2.5 border-r">{a.locationCode}</td>
                                                                    <td className="px-4 py-2.5 border-r font-bold">{formatQuantity(a.quantity)}</td>
                                                                    <td className="px-4 py-2.5 border-r">{a.bbd}</td>
                                                                    <td className="px-4 py-2.5 font-mono">{a.batch}</td>
                                                                </tr>
                                                            ))}
                                                        </tbody>
                                                    </table>
                                                </div>
                                            </div>

                                            {/* 3. Breakdown Table */}
                                            <div className="mt-8">
                                                <h3 className="text-xl font-bold mb-3">Breakdown</h3>
                                                <div className="border border-slate-200 rounded-lg overflow-hidden">
                                                    <table className="w-full text-[11px] text-center">
                                                        <thead className="bg-slate-50 border-b border-slate-200 font-bold">
                                                            <tr>
                                                                <th className="px-2 py-2 border-r w-12">Select</th>
                                                                <th className="px-4 py-2 text-left border-r">Location</th>
                                                                <th className="px-4 py-2 border-r">Quantity</th>
                                                                <th className="px-4 py-2 border-r">Best Before</th>
                                                                <th className="px-4 py-2">Batch No</th>
                                                            </tr>
                                                        </thead>
                                                        <tbody>
                                                            {stockBreakdown.length === 0 ? (
                                                                <tr><td colSpan={5} className="py-4 text-slate-300 italic">No items found</td></tr>
                                                            ) : stockBreakdown.map((s, i) => (
                                                                <tr key={i} className="border-b border-slate-100 hover:bg-slate-50 cursor-pointer" onClick={() => {
                                                                    setSelectedLocation(s.locationId);
                                                                    setBatchNumber(s.batchNumber || '');
                                                                    if(s.bestBeforeDate) setBestBeforeDate(dayjs(s.bestBeforeDate));
                                                                }}>
                                                                    <td className="px-2 py-2.5 border-r"><input type="checkbox" checked={selectedLocation === s.locationId} readOnly className="cursor-pointer" /></td>
                                                                    <td className="px-4 py-2.5 text-left border-r font-semibold">{s.Location?.name || s.Location?.code || '—'}</td>
                                                                    <td className="px-4 py-2.5 border-r">{formatQuantity(s.quantity)}</td>
                                                                    <td className="px-4 py-2.5 border-r">{s.bestBeforeDate ? dayjs(s.bestBeforeDate).format('DD/MM/YYYY') : '—'}</td>
                                                                    <td className="px-4 py-2.5 font-mono italic">{s.batchNumber || '—'}</td>
                                                                </tr>
                                                            ))}
                                                        </tbody>
                                                    </table>
                                                </div>
                                            </div>

                                            {/* 4. Action Details Section */}
                                            <div className="mt-12 space-y-4 max-w-[400px]">
                                                <div className="flex items-center gap-4">
                                                    <label className="text-[11px] font-black text-slate-500 uppercase tracking-widest w-32">Location</label>
                                                    <Select
                                                        showSearch optionFilterProp="label"
                                                        placeholder="Pick Location"
                                                        className="flex-1" size="large"
                                                        allowClear
                                                        value={selectedLocation}
                                                        onChange={setSelectedLocation}
                                                        options={filteredLocations.map(l => ({ value: l.id, label: l.name || l.code }))}
                                                    />
                                                </div>
                                                <div className="flex items-center gap-4">
                                                    <label className="text-[11px] font-black text-slate-500 uppercase tracking-widest w-32">Quantity</label>
                                                    <InputNumber
                                                        min={1} value={qty} onChange={setQty}
                                                        className="flex-1 rounded-xl h-10 flex items-center text-base font-bold"
                                                    />
                                                </div>
                                                <div className="flex items-center gap-4">
                                                    <label className="text-[11px] font-black text-slate-500 uppercase tracking-widest w-32">Best Before</label>
                                                    <DatePicker
                                                        className="flex-1 rounded-xl h-10"
                                                        format="DD/MM/YYYY"
                                                        value={bestBeforeDate}
                                                        onChange={setBestBeforeDate}
                                                    />
                                                </div>
                                                <div className="flex items-center gap-4">
                                                    <label className="text-[11px] font-black text-slate-500 uppercase tracking-widest w-32">Batch No</label>
                                                    <Input
                                                        placeholder="Batch ID"
                                                        className="flex-1 rounded-xl h-10"
                                                        value={batchNumber}
                                                        onChange={e => setBatchNumber(e.target.value)}
                                                    />
                                                </div>
                                                <div className="flex items-center gap-4">
                                                    <label className="text-[11px] font-black text-slate-500 uppercase tracking-widest w-32">Reason</label>
                                                    <Input
                                                        placeholder="Manual Entry"
                                                        className="flex-1 rounded-xl h-10"
                                                        value={reason}
                                                        onChange={e => setReason(e.target.value)}
                                                    />
                                                </div>
                                            </div>

                                        </>
                                    )}
                                </div>


                            <Divider className="my-1 border-slate-50" />


                            {/* Quantity & Actions */}
                            <div className="space-y-5">
                                <div className="flex-1">
                                    <label className="text-[10px] font-black text-slate-400 uppercase tracking-widest block mb-2 ml-1">Quantity to Book</label>
                                    <div className="flex gap-2">
                                        <InputNumber
                                            ref={qtyRef}
                                            min={1}
                                            precision={0}
                                            value={qty}
                                            onChange={setQty}
                                            className="w-full rounded-xl h-12 flex items-center text-lg font-black bg-slate-50 border-slate-200"
                                            onKeyDown={(e) => {
                                                if(e.key === 'Enter') handleAction('INCREASE');
                                            }}
                                        />
                                        <div className="grid grid-cols-2 gap-1 shrink-0">
                                            {[1, 10, 50, 100].map(n => (
                                                <Button 
                                                    key={n} 
                                                    size="small" 
                                                    className="text-[9px] font-bold h-5 px-1 rounded bg-slate-100 border-slate-200 hover:bg-slate-200"
                                                    onClick={() => setQty(n)}
                                                >
                                                    {n}
                                                </Button>
                                            ))}
                                        </div>
                                    </div>
                                </div>

                                <div className="grid grid-cols-2 gap-4">
                                    <button
                                        onClick={() => handleAction('INCREASE')}
                                        disabled={processing || !selectedProduct || !selectedWarehouse || !selectedLocation || !selectedClient || !canCreate(user?.role)}
                                        className="flex items-center justify-center gap-2 py-2 bg-emerald-500 hover:bg-emerald-600 active:scale-95 transition-all rounded-full text-white shadow-md shadow-emerald-200/40 disabled:opacity-30 disabled:cursor-not-allowed"
                                    >
                                        <ArrowUpOutlined className="text-xs" />
                                        <span className="text-[10px] font-black uppercase italic tracking-tighter">Stock IN</span>
                                    </button>
                                    <button
                                        onClick={() => handleAction('DECREASE')}
                                        disabled={processing || !selectedProduct || !selectedWarehouse || !selectedLocation || !selectedClient || !canCreate(user?.role)}
                                        className="flex items-center justify-center gap-2 py-2 bg-rose-500 hover:bg-rose-600 active:scale-95 transition-all rounded-full text-white shadow-md shadow-rose-200/40 disabled:opacity-30 disabled:cursor-not-allowed"
                                    >
                                        <ArrowDownOutlined className="text-xs" />
                                        <span className="text-[10px] font-black uppercase italic tracking-tighter">Stock OUT</span>
                                    </button>
                                </div>
                            </div>

                            {/* Optional Details Hidden per user request */}
                        </div>
                    </Card>
                </div>

                {/* RIGHT COLUMN — Live Feed Activity (Collapsible) */}
                {!historyCollapsed && (
                    <div className="lg:col-span-5 min-w-0 animate-in slide-in-from-right duration-300">
                        <Card
                            className="rounded-2xl shadow-sm border-gray-100 flex flex-col"
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
                                <span className="text-[10px] font-black uppercase tracking-widest text-slate-400">Loading history...</span>
                            </div>
                        ) : history.length === 0 ? (
                            <div className="py-24 text-center">
                                <Empty image={Empty.PRESENTED_IMAGE_SIMPLE} description={<span className="text-slate-400 font-bold italic">No inventory booked yet</span>} />
                            </div>
                        ) : (
                            <div className="divide-y divide-slate-100 max-h-[calc(100vh-200px)] overflow-y-auto custom-scrollbar">
                                {history.map((entry, idx) => {
                                    const isIncrease = (entry.quantity || 0) > 0 || entry.type === 'INCREASE' || entry.reason === 'SCAN_IN';
                                    const prod = entry.Product || entry.product || products.find((p) => Number(p.id) === Number(entry.productId)) || {};
                                    const dateStr = dayjs(entry.createdAt).format('DD/MM/YYYY, HH:mm:ss');
                                    const displayQty = formatQuantity(Math.abs(entry.quantity || 0));

                                    return (
                                        <div key={entry.id || idx} className="flex gap-3 px-4 py-4 hover:bg-slate-50 transition-all border-b border-slate-100 overflow-x-hidden">
                                            {/* Action Status Box (Shrinked & More Rounded) */}
                                            <div className={`w-9 h-9 rounded-md flex items-center justify-center shrink-0 font-black text-xs text-white ${
                                                isIncrease ? 'bg-[#4CAF50]' : 'bg-[#FF0000]'
                                            }`}>
                                                {isIncrease ? '+' : '-'}{displayQty}
                                            </div>
                                            
                                            <div className="flex-1 min-w-0">
                                                <div className="flex flex-col gap-1">
                                                    <p className="font-black text-slate-900 text-[13px] leading-tight truncate">
                                                        {prod.sku || 'N/A'} <span className="text-[11px] font-medium text-slate-400">— {prod.name}</span>
                                                    </p>
                                                    
                                                    <div className="grid grid-cols-1 gap-2 mt-2 text-[10px] font-bold text-slate-600">
                                                        <div className="flex gap-2">
                                                            <div className="flex-1 min-w-0">
                                                                <span className="text-slate-400 font-medium">WH:</span>
                                                                <p className="bg-slate-100 px-1.5 py-0.5 mt-0.5 rounded-sm truncate">{entry.Warehouse?.name || 'Main'}</p>
                                                            </div>
                                                            <div className="flex-1 min-w-0">
                                                                <span className="text-slate-400 font-medium">Loc:</span>
                                                                <p className="bg-slate-100 px-1.5 py-0.5 mt-0.5 rounded-sm truncate">{entry.Location?.name || entry.Location?.code || '—'}</p>
                                                            </div>
                                                        </div>
                                                        <div className="flex gap-2">
                                                            <div className="flex-1 min-w-0">
                                                                <span className="text-slate-400 font-medium">Exp/Batch:</span>
                                                                <p className="bg-slate-100 px-1.5 py-0.5 mt-0.5 rounded-sm truncate">
                                                                    {entry.bestBeforeDate ? dayjs(entry.bestBeforeDate).format('DD/MM/YY') : '—'} | {entry.batchNumber || '—'}
                                                                </p>
                                                            </div>
                                                            <div className="flex-1 min-w-0">
                                                                <span className="text-slate-400 font-medium">Client:</span>
                                                                <p className="bg-slate-100 px-1.5 py-0.5 mt-0.5 rounded-sm truncate">{entry.Client?.name || 'KIAAN'}</p>
                                                            </div>
                                                        </div>
                                                    </div>

                                                    <div className="mt-2 pt-2 border-t border-slate-50 flex justify-between items-center opacity-70">
                                                        <span className="text-[9px] text-slate-400 font-black uppercase">{dateStr}</span>
                                                        <span className="text-[9px] text-blue-500 truncate max-w-[120px]">{entry.User?.email || 'system'}</span>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                    );
                                })}
                            </div>
                        )}

                    </Card>
                </div>
                )}

                {/* COLLAPSED SIDEBAR HANDLE */}
                {historyCollapsed && (
                    <div className="w-12 h-screen fixed right-0 top-0 bg-white border-l border-slate-100 flex flex-col items-center pt-24 gap-12 animate-in slide-in-from-right duration-300 z-50 shadow-2xl">
                        <Button 
                            type="text" 
                            shape="circle" 
                            icon={<ArrowLeftOutlined />} 
                            onClick={() => setHistoryCollapsed(false)} 
                            className="text-slate-400 hover:text-indigo-600 hover:bg-slate-50"
                        />
                        <div className="[writing-mode:vertical-lr] rotate-180 font-black text-[10px] tracking-[0.4em] text-slate-300 uppercase">
                            Activity Feed
                        </div>
                    </div>
                )}
            </div>

            <style dangerouslySetInnerHTML={{ __html: `
                .custom-scrollbar::-webkit-scrollbar { width: 5px; }
                .custom-scrollbar::-webkit-scrollbar-track { background: transparent; }
                .custom-scrollbar::-webkit-scrollbar-thumb { background: #e2e8f0; border-radius: 10px; }
                .custom-scrollbar::-webkit-scrollbar-thumb:hover { background: #cbd5e1; }
            `}} />
        </MainLayout>
    );
};

export default BookInventory;
