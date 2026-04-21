import React, { useState, useEffect, useCallback } from 'react';
import { Table, Button, Input, Select, Tag, Card, Modal, Form, message, Space, InputNumber, Divider, Typography, Upload } from 'antd';
import {
    SearchOutlined,
    ReloadOutlined,
    PlusOutlined,
    DeleteOutlined,
    UploadOutlined,
    DownloadOutlined,
    LinkOutlined,
} from '@ant-design/icons';
import { apiRequest } from '../../api/client';
import { useAuthStore } from '../../store/authStore';
import { MainLayout } from '../../components/layout/MainLayout';

const { Search } = Input;
const { Option } = Select;

export default function SupplierProducts() {
    const { token } = useAuthStore();
    const [loading, setLoading] = useState(false);
    const [mappings, setMappings] = useState([]);
    const [suppliers, setSuppliers] = useState([]);
    const [products, setProducts] = useState([]);
    const [searchText, setSearchText] = useState('');
    const [createModalOpen, setCreateModalOpen] = useState(false);
    const [form] = Form.useForm();

    const fetchData = useCallback(async () => {
        if (!token) return;
        setLoading(true);
        try {
            const [mapRes, supRes, prodRes] = await Promise.all([
                apiRequest('/api/supplier-products', { method: 'GET' }, token),
                apiRequest('/api/suppliers', { method: 'GET' }, token),
                apiRequest('/api/inventory/products', { method: 'GET' }, token),
            ]);
            setMappings(mapRes.data || []);
            setSuppliers(supRes.data || []);
            setProducts(prodRes.data || []);
        } catch (err) {
            message.error('Failed to load data');
        } finally {
            setLoading(false);
        }
    }, [token]);

    useEffect(() => {
        fetchData();
    }, [fetchData]);

    const handleCreate = async (values) => {
        // Since we only have bulk upload in the controller right now, 
        // let's just use the same bulk upload endpoint for single creation as well
        try {
            const product = products.find(p => p.id === values.productId);
            const mapping = {
                supplierId: values.supplierId,
                sku: product?.sku,
                supplierSku: values.supplierSku,
                supplierProductName: values.supplierProductName,
                packSize: values.packSize,
                costPrice: values.costPrice
            };
            await apiRequest('/api/supplier-products/bulk-upload', {
                method: 'POST',
                body: JSON.stringify([mapping])
            }, token);
            message.success('Mapping created!');
            setCreateModalOpen(false);
            form.resetFields();
            fetchData();
        } catch (err) {
            message.error('Failed to create mapping');
        }
    };

    const handleDelete = async (id) => {
        try {
            await apiRequest(`/api/supplier-products/${id}`, { method: 'DELETE' }, token);
            message.success('Mapping deleted');
            fetchData();
        } catch (err) {
            message.error('Delete failed');
        }
    };

    const handleBulkUpload = async (info) => {
        if (info.file.status === 'done' || info.file.status === 'uploading') {
            const reader = new FileReader();
            reader.onload = async (e) => {
                const text = e.target.result;
                const rows = text.split('\n').filter(r => r.trim());
                const header = rows[0].split(',').map(h => h.trim());
                const data = rows.slice(1).map(row => {
                    const values = row.split(',').map(v => v.trim());
                    const obj = {};
                    header.forEach((h, i) => obj[h] = values[i]);
                    return obj;
                });
                
                try {
                    const res = await apiRequest('/api/supplier-products/bulk-upload', {
                        method: 'POST',
                        body: JSON.stringify(data)
                    }, token);
                    message.success(`Uploaded: ${res.results.created} created, ${res.results.updated} updated`);
                    fetchData();
                } catch (err) {
                    message.error('Bulk upload failed');
                }
            };
            reader.readAsText(info.file.originFileObj || info.file);
        }
    };

    const exportCsv = () => {
        const header = "supplierName,sku,supplierSku,supplierProductName,packSize,costPrice\n";
        const rows = mappings.map(m => 
            `${m.Supplier?.name},${m.Product?.sku},${m.supplierSku || ''},${m.supplierProductName || ''},${m.packSize},${m.costPrice}`
        ).join('\n');
        const blob = new Blob([header + rows], { type: 'text/csv' });
        const url = window.URL.createObjectURL(blob);
        const a = document.createElement('a');
        a.href = url;
        a.download = 'supplier_product_mapping.csv';
        a.click();
    };

    const filteredMappings = mappings.filter(m => {
        const q = searchText.toLowerCase();
        return (
            (m.Supplier?.name || '').toLowerCase().includes(q) ||
            (m.Product?.name || '').toLowerCase().includes(q) ||
            (m.Product?.sku || '').toLowerCase().includes(q) ||
            (m.supplierSku || '').toLowerCase().includes(q)
        );
    });

    const columns = [
        { title: 'Supplier', dataIndex: ['Supplier', 'name'], key: 'supplier' },
        { title: 'Internal Product', dataIndex: ['Product', 'name'], key: 'product' },
        { title: 'Internal SKU', dataIndex: ['Product', 'sku'], key: 'sku' },
        { title: 'Supplier SKU', dataIndex: 'supplierSku', key: 'supplierSku' },
        { title: 'Supplier Name', dataIndex: 'supplierProductName', key: 'supplierProductName' },
        { title: 'Pack Size', dataIndex: 'packSize', key: 'packSize' },
        { title: 'Cost Price', dataIndex: 'costPrice', key: 'costPrice', render: (v) => `$${Number(v).toFixed(2)}` },
        {
            title: 'Actions',
            key: 'actions',
            render: (_, r) => (
                <Button type="link" danger icon={<DeleteOutlined />} onClick={() => handleDelete(r.id)} />
            )
        }
    ];

    return (
        <MainLayout>
            <div className="space-y-6">
                <div className="flex justify-between items-center">
                    <div>
                        <h1 className="text-2xl font-bold flex items-center gap-2">
                            <LinkOutlined className="text-blue-600" /> Supplier Product Mapping
                        </h1>
                        <p className="text-gray-500">Link your products with supplier SKUs and pricing</p>
                    </div>
                    <Space>
                        <Upload customRequest={({ onSuccess }) => onSuccess('ok')} onChange={handleBulkUpload} showUploadList={false}>
                            <Button icon={<UploadOutlined />}>Bulk Upload CSV</Button>
                        </Upload>
                        <Button icon={<DownloadOutlined />} onClick={exportCsv}>Export CSV</Button>
                        <Button type="primary" icon={<PlusOutlined />} onClick={() => setCreateModalOpen(true)}>New Mapping</Button>
                    </Space>
                </div>

                <Card>
                    <Search
                        placeholder="Search mapping..."
                        onChange={(e) => setSearchText(e.target.value)}
                        className="max-w-md mb-4"
                        prefix={<SearchOutlined />}
                        allowClear
                    />
                    <Table columns={columns} dataSource={filteredMappings} rowKey="id" loading={loading} />
                </Card>

                <Modal
                    title="Create Supplier Mapping"
                    open={createModalOpen}
                    onCancel={() => setCreateModalOpen(false)}
                    onOk={() => form.submit()}
                >
                    <Form form={form} layout="vertical" onFinish={handleCreate}>
                        <Form.Item name="supplierId" label="Supplier" rules={[{ required: true }]}>
                            <Select showSearch optionFilterProp="label" options={suppliers.map(s => ({ value: s.id, label: s.name }))} />
                        </Form.Item>
                        <Form.Item name="productId" label="Internal Product" rules={[{ required: true }]}>
                            <Select showSearch optionFilterProp="label" options={products.map(p => ({ value: p.id, label: `${p.name} (${p.sku})` }))} />
                        </Form.Item>
                        <Form.Item name="supplierSku" label="Supplier SKU">
                            <Input placeholder="Supplier's SKU code..." />
                        </Form.Item>
                        <Form.Item name="supplierProductName" label="Supplier Product Name">
                            <Input placeholder="Supplier's product name..." />
                        </Form.Item>
                        <div className="grid grid-cols-2 gap-4">
                            <Form.Item name="packSize" label="Pack Size" initialValue={1}>
                                <InputNumber min={1} className="w-full" />
                            </Form.Item>
                            <Form.Item name="costPrice" label="Cost Price" initialValue={0}>
                                <InputNumber min={0} step={0.01} className="w-full" />
                            </Form.Item>
                        </div>
                    </Form>
                </Modal>
            </div>
        </MainLayout>
    );
}
