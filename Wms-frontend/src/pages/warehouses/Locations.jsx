import React, { useState, useEffect, useCallback } from 'react';
import { Table, Button, Input, InputNumber, Select, Tag, Space, Card, Form, Modal, message, Popconfirm, Upload } from 'antd';
import { PlusOutlined, SearchOutlined, EditOutlined, DeleteOutlined, EyeOutlined, ReloadOutlined, EnvironmentOutlined, HomeOutlined, DownloadOutlined, UploadOutlined, FileTextOutlined } from '@ant-design/icons';
import { MainLayout } from '../../components/layout/MainLayout';
import { useAuthStore } from '../../store/authStore';
import { apiRequest, API_BASE_URL } from '../../api/client';

const { Search } = Input;
const { Option } = Select;

const LOCATION_TYPE_LABELS = { PICK: 'Pick', BULK: 'Bulk', QUARANTINE: 'Quarantine', STAGING: 'Staging' };

export default function WarehouseLocations() {
    const { token } = useAuthStore();
    const [loading, setLoading] = useState(false);
    const [locations, setLocations] = useState([]);
    const [zones, setZones] = useState([]);
    const [warehouses, setWarehouses] = useState([]);
    const [searchText, setSearchText] = useState('');
    const [selectedLocation, setSelectedLocation] = useState(null);
    const [modalOpen, setModalOpen] = useState(false);
    const [importModalOpen, setImportModalOpen] = useState(false);
    const [fileList, setFileList] = useState([]);
    const [uploading, setUploading] = useState(false);
    const [viewMode, setViewMode] = useState(false);
    const [saving, setSaving] = useState(false);
    const [importResults, setImportResults] = useState(null);
    const [form] = Form.useForm();
    const selectedWarehouseId = Form.useWatch('warehouseId', form);

    const fetchLocations = useCallback(async () => {
        if (!token) return;
        try {
            setLoading(true);
            const timestamp = new Date().getTime();
            const data = await apiRequest(`/api/locations?_t=${timestamp}`, { method: 'GET', cache: 'no-store' }, token);
            const list = Array.isArray(data?.data) ? data.data : Array.isArray(data) ? data : [];
            setLocations(list);
        } catch (err) {
            message.error(err.message || 'Failed to load locations');
            setLocations([]);
        } finally {
            setLoading(false);
        }
    }, [token]);

    const fetchZones = useCallback(async () => {
        if (!token) return;
        try {
            const data = await apiRequest('/api/zones', { method: 'GET' }, token);
            setZones(Array.isArray(data?.data) ? data.data : []);
        } catch {
            setZones([]);
        }
    }, [token]);

    const fetchWarehouses = useCallback(async () => {
        if (!token) return;
        try {
            const data = await apiRequest('/api/warehouses', { method: 'GET' }, token);
            setWarehouses(Array.isArray(data?.data) ? data.data : []);
        } catch {
            setWarehouses([]);
        }
    }, [token]);

    useEffect(() => {
        if (token) {
            fetchLocations();
            fetchZones();
            fetchWarehouses();
        }
    }, [token, fetchLocations, fetchZones, fetchWarehouses]);

    const zonesByWarehouse = selectedWarehouseId ? zones.filter(z => z.warehouseId === selectedWarehouseId) : zones;

    const handleSubmit = async (values) => {
        try {
            setSaving(true);
            const payload = {
                name: values.name,
                zoneId: values.zoneId,
                code: values.code,
                aisle: values.aisle,
                rack: values.rack,
                shelf: values.shelf,
                bin: values.bin,
                locationType: values.locationType,
                pickSequence: values.pickSequence,
                maxWeight: values.maxWeight,
                heatSensitive: values.heatSensitive,
            };
            if (selectedLocation) {
                await apiRequest(`/api/locations/${selectedLocation.id}`, { method: 'PUT', body: JSON.stringify(payload) }, token);
                message.success('Location updated');
            } else {
                await apiRequest('/api/locations', { method: 'POST', body: JSON.stringify(payload) }, token);
                message.success('Location created');
            }
            setModalOpen(false);
            form.resetFields();
            setSelectedLocation(null);
            fetchLocations();
        } catch (err) {
            message.error(err.message || 'Failed to save location');
        } finally {
            setSaving(false);
        }
    };

    const handleDelete = async (id) => {
        try {
            await apiRequest(`/api/locations/${id}`, { method: 'DELETE' }, token);
            message.success('Location deleted');
            fetchLocations();
        } catch (err) {
            message.error(err?.message || 'Failed to delete');
        }
    };

    const handleDownloadSample = () => {
        const headers = ['zoneId', 'zoneName', 'warehouseName', 'aisle', 'rack', 'shelf', 'bin', 'locationType', 'pickSequence', 'maxWeight'];
        const sampleRow = [zones[0]?.id || '', zones[0]?.name || 'Main Zone', zones[0]?.Warehouse?.name || 'Main Warehouse', 'A', '01', '1', '1', 'PICK', '1', '100'];
        const csvContent = [headers.join(','), sampleRow.join(',')].join('\n');
        const blob = new Blob([csvContent], { type: 'text/csv;charset=utf-8;' });
        const url = URL.createObjectURL(blob);
        const link = document.createElement('a');
        link.href = url;
        link.download = 'sample_locations_import.csv';
        link.click();
    };

    const handleExport = () => {
        try {
            if (locations.length === 0) {
                message.warning('No locations to export');
                return;
            }

            const headers = ['zoneId', 'name', 'code', 'aisle', 'rack', 'shelf', 'bin', 'locationType', 'pickSequence', 'maxWeight', 'heatSensitive'];
            const rows = locations.map(l => [
                l.zoneId ?? '',
                l.name || '',
                l.code || '',
                l.aisle || '',
                l.rack || '',
                l.shelf || '',
                l.bin || '',
                l.locationType || '',
                l.pickSequence ?? '',
                l.maxWeight ?? '',
                l.heatSensitive || '',
            ]);

            const csvContent = [
                headers.join(','),
                ...rows.map(r => r.map(v => `"${String(v).replace(/"/g, '""')}"`).join(','))
            ].join('\n');

            const blob = new Blob([csvContent], { type: 'text/csv;charset=utf-8;' });
            const url = URL.createObjectURL(blob);
            const link = document.createElement('a');
            link.setAttribute('href', url);
            link.setAttribute('download', `warehouse_locations_${new Date().toISOString().split('T')[0]}.csv`);
            link.style.visibility = 'hidden';
            document.body.appendChild(link);
            link.click();
            document.body.removeChild(link);
            message.success('Export completed');
        } catch (err) {
            message.error('Export failed');
        }
    };

    const readFileText = (file) => new Promise((resolve, reject) => {
        const reader = new FileReader();
        reader.onload = () => resolve(String(reader.result || ''));
        reader.onerror = () => reject(new Error('Unable to read CSV file'));
        reader.readAsText(file);
    });

    const validateImportCsv = async (file) => {
        const text = await readFileText(file);
        const lines = text.split(/\r?\n/).map((line) => line.trim()).filter(Boolean);
        if (lines.length < 2) throw new Error('CSV must contain header and at least one data row');

        const headers = lines[0].split(',').map((h) => h.replace(/^"|"$/g, '').trim().toLowerCase());
        const zoneIndex = headers.findIndex((h) => ['zoneid', 'zone_id', 'zone id'].includes(h));
        const zoneNameIndex = headers.findIndex((h) => ['zonename', 'zone_name', 'zone name', 'zone'].includes(h));
        if (zoneIndex < 0 && zoneNameIndex < 0) throw new Error('Missing required header: zoneId or zoneName');

        const firstDataRows = lines.slice(1, 6);
        for (let i = 0; i < firstDataRows.length; i += 1) {
            const cols = firstDataRows[i].split(',').map((c) => c.replace(/^"|"$/g, '').trim());
            const zoneIdValue = zoneIndex >= 0 ? cols[zoneIndex] : '';
            const zoneNameValue = zoneNameIndex >= 0 ? cols[zoneNameIndex] : '';
            if (!zoneIdValue && !zoneNameValue) {
                throw new Error(`Row ${i + 2}: zoneId or zoneName is required.`);
            }
        }
    };

    const handleImport = async () => {
        if (fileList.length === 0) {
            message.error('Please select a file to upload');
            return;
        }

        const file = fileList[0];
        const formData = new FormData();
        formData.append('file', file);

        try {
            setUploading(true);
            setImportResults(null);

            const response = await fetch(`${API_BASE_URL}/api/locations/bulk-upload`, {
                method: 'POST',
                headers: { 'Authorization': `Bearer ${token}` }, // Do not set Content-Type manually
                body: formData
            });

            const data = await response.json();
            if (data.success) {
                setImportResults(data);
                const fails = Number(data.failureCount || 0);
                const succs = Number(data.successCount || 0);
                const created = Number(data.createdCount || 0);
                const updated = Number(data.updatedCount || 0);

                if (fails === 0) {
                    message.success(`${succs} rows processed (${created} created, ${updated} updated)`);
                    if (created === 0 && updated > 0) {
                        message.info('No new locations were added. Existing locations were updated.');
                    }
                    setImportModalOpen(false);
                    setFileList([]);
                } else {
                    message.warning(`Processed with ${fails} errors (${created} created, ${updated} updated). Check details below.`);
                }

                // Fetch updated locations after successful import
                await fetchLocations();

                // Reset pagination to the first page if pagination is implemented
                setPage(1);
                setSearchText('');
            } else {
                throw new Error(data.message || 'Import failed');
            }
        } catch (err) {
            message.error(err.message || 'Failed to fetch. Please check your network or server configuration.');
        } finally {
            setUploading(false);
        }
    };

    const setFormValues = (r) => {
        const whId = r.Zone?.warehouseId ?? (r.zoneId && zones.find(z => z.id === r.zoneId)?.warehouseId);
        form.setFieldsValue({
            name: r.name,
            code: r.code,
            warehouseId: whId,
            zoneId: r.zoneId,
            aisle: r.aisle,
            rack: r.rack,
            shelf: r.shelf,
            bin: r.bin,
            locationType: r.locationType,
            pickSequence: r.pickSequence,
            maxWeight: r.maxWeight,
            heatSensitive: r.heatSensitive,
        });
    };

    const filteredLocations = locations.filter(l => {
        if (!searchText) return true;
        const s = searchText.toLowerCase();
        const name = (l.name || '').toLowerCase();
        const code = (l.code || '').toLowerCase();
        const whName = (l.Zone?.Warehouse?.name || '').toLowerCase();
        const whCode = (l.Zone?.Warehouse?.code || '').toLowerCase();
        return name.includes(s) || code.includes(s) || whName.includes(s) || whCode.includes(s);
    });

    const columns = [
        { title: 'Location Name', dataIndex: 'name', key: 'name', width: 160, render: (v) => <span className="flex items-center gap-2 font-medium text-blue-600"><EnvironmentOutlined className="text-gray-400" />{v || '—'}</span> },
        {
            title: 'Last Updated',
            dataIndex: 'updatedAt',
            key: 'updatedAt',
            width: 170,
            render: (v) => v ? new Date(v).toLocaleString() : '—'
        },
        { title: 'Warehouse', key: 'wh', width: 180, render: (_, r) => r.Zone?.Warehouse ? <span className="flex items-center gap-2"><HomeOutlined className="text-gray-400" />{r.Zone.Warehouse.name} ({r.Zone.Warehouse.code})</span> : '—' },
        { title: 'Aisle', dataIndex: 'aisle', key: 'aisle', width: 80, render: (v) => v ?? '—' },
        { title: 'Rack', dataIndex: 'rack', key: 'rack', width: 80, render: (v) => v ?? '—' },
        { title: 'Shelf', dataIndex: 'shelf', key: 'shelf', width: 80, render: (v) => v ?? '—' },
        { title: 'Bin', dataIndex: 'bin', key: 'bin', width: 80, render: (v) => v ?? '—' },
        { title: 'Location Type', dataIndex: 'locationType', key: 'type', width: 110, render: (t) => t ? <Tag color={t === 'PICK' ? 'green' : t === 'BULK' ? 'blue' : 'orange'}>{t}</Tag> : '—' },
        { title: 'Pick Sequence', dataIndex: 'pickSequence', key: 'seq', width: 100, render: (v) => v != null ? v : '—' },
        { title: 'Max Weight (kg)', dataIndex: 'maxWeight', key: 'maxWeight', width: 110, render: (v) => v != null ? v : '—' },
        { title: 'Heat Sensitive', dataIndex: 'heatSensitive', key: 'heat', width: 100, render: (v) => v ? <Tag color="orange">{String(v)}</Tag> : '—' },
        {
            title: 'Actions',
            key: 'act',
            width: 140,
            fixed: 'right',
            render: (_, r) => (
                <Space>
                    <Button type="link" size="small" icon={<EyeOutlined />} className="text-blue-600 p-0 font-normal" onClick={() => { setSelectedLocation(r); setViewMode(true); setModalOpen(true); setFormValues(r); }}>View</Button>
                    <Button type="text" size="small" icon={<EditOutlined className="text-blue-600" />} onClick={() => { setSelectedLocation(r); setViewMode(false); setFormValues(r); setModalOpen(true); }} />
                    <Popconfirm title="Delete this location?" onConfirm={() => handleDelete(r.id)} okText="Yes" cancelText="No">
                        <Button type="text" size="small" danger icon={<DeleteOutlined />} />
                    </Popconfirm>
                </Space>
            )
        }
    ];

    const [page, setPage] = useState(1); // Added pagination state

    return (
        <MainLayout>
            <div className="space-y-6 animate-in fade-in duration-500 pb-12">
                <div className="flex justify-between items-center">
                    <div>
                        <h1 className="text-2xl font-medium text-blue-600">Warehouse Locations</h1>
                        <p className="text-gray-500 text-sm mt-0.5">Manage storage locations across warehouses</p>
                    </div>
                    <Space>
                        <Button icon={<DownloadOutlined />} onClick={handleExport}>
                            Export CSV
                        </Button>
                        <Button icon={<UploadOutlined />} onClick={() => setImportModalOpen(true)}>
                            Import CSV
                        </Button>
                        <Button type="primary" icon={<PlusOutlined />} className="bg-blue-600 border-blue-600 rounded-lg" onClick={() => { setSelectedLocation(null); setViewMode(false); form.resetFields(); setModalOpen(true); }}>
                            Add Location
                        </Button>
                    </Space>
                </div>

                <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
                    <Card className="rounded-xl border-gray-100 shadow-sm">
                        <div className="flex flex-col gap-1">
                            <div className="text-xs text-gray-500 font-normal">Total Locations</div>
                            <div className="text-2xl font-medium text-blue-600">{locations.length}</div>
                        </div>
                    </Card>
                    <Card className="rounded-xl border-gray-100 shadow-sm">
                        <div className="flex flex-col gap-1">
                            <div className="text-xs text-gray-500 font-normal">Pick</div>
                            <div className="text-2xl font-medium text-green-600">{locations.filter(l => l.locationType === 'PICK').length}</div>
                        </div>
                    </Card>
                    <Card className="rounded-xl border-gray-100 shadow-sm">
                        <div className="flex flex-col gap-1">
                            <div className="text-xs text-gray-500 font-normal">Bulk</div>
                            <div className="text-2xl font-medium text-blue-600">{locations.filter(l => l.locationType === 'BULK').length}</div>
                        </div>
                    </Card>
                    <Card className="rounded-xl border-gray-100 shadow-sm">
                        <div className="flex flex-col gap-1">
                            <div className="text-xs text-gray-500 font-normal">Warehouses</div>
                            <div className="text-2xl font-medium text-purple-600">{new Set(locations.map(l => l.Zone?.Warehouse?.id).filter(Boolean)).size}</div>
                        </div>
                    </Card>
                </div>

                <Card className="rounded-xl shadow-sm border-gray-100 overflow-hidden">
                    <div className="p-6">
                        <div className="mb-4 flex flex-wrap items-center gap-3">
                            <Search placeholder="Search by location name, code, or warehouse..." className="max-w-md" prefix={<SearchOutlined />} value={searchText} onChange={e => setSearchText(e.target.value)} allowClear />
                            <Button icon={<SearchOutlined />} className="bg-blue-600 border-blue-600 text-white">Search</Button>
                            <Button icon={<ReloadOutlined />} onClick={fetchLocations}>Refresh</Button>
                        </div>
                        <Table
                            columns={columns}
                            dataSource={filteredLocations}
                            rowKey="id"
                            loading={loading}
                            pagination={{
                                current: page,
                                onChange: (nextPage) => setPage(nextPage),
                                showSizeChanger: true,
                                showTotal: (t) => `Total ${t} locations`,
                                pageSize: 10
                            }}
                            scroll={{ x: 1200 }}
                            className="[&_.ant-table-thead_th]:font-normal"
                        />
                    </div>
                </Card>

                <Modal
                    title="Bulk Import Locations"
                    open={importModalOpen}
                    onCancel={() => { if (!uploading) { setImportModalOpen(false); setImportResults(null); setFileList([]); } }}
                    onOk={handleImport}
                    confirmLoading={uploading}
                    okText={importResults ? "Upload Another" : "Upload & Import"}
                    okButtonProps={{ className: 'bg-blue-600 border-blue-600' }}
                    width={720}
                >
                    <div className="space-y-4 pt-2">
                        {!importResults && (
                            <div className="p-4 bg-blue-50 border border-blue-100 rounded-lg">
                                <div className="flex justify-between items-start mb-2">
                                    <div className="text-blue-700 text-sm font-medium flex items-center gap-2">
                                        <FileTextOutlined /> CSV Format Requirement
                                    </div>
                                    <Button type="link" size="small" icon={<DownloadOutlined />} className="p-0 h-auto" onClick={handleDownloadSample}>Download Sample</Button>
                                </div>
                                <ul className="text-blue-600 text-[11px] list-disc pl-4 space-y-1">
                                    <li>Headers: <b>zoneId/zoneName, optional warehouseId/warehouseName, aisle, rack, shelf, bin, locationType, pickSequence, maxWeight</b></li>
                                    <li><b>zoneId</b> de sakte hain, ya <b>zoneName</b>. Agar zoneName naya ho to system zone auto-create karega.</li>
                                    <li>Naya zone create karte waqt <b>warehouseId</b> ya <b>warehouseName</b> dena best hai (especially multiple warehouses case).</li>
                                    <li>Location name will be auto-generated as <b>Aisle+Rack+Shelf+Bin</b> (e.g., 102C1).</li>
                                    <li>Only <b>bulk, pick, quarantine, staging</b> are allowed for locationType.</li>
                                </ul>
                            </div>
                        )}

                        {importResults && (
                            <div className="p-4 rounded-lg border border-gray-100 space-y-3">
                                <div className="flex gap-4">
                                    <div className="flex-1 p-3 bg-green-50 rounded-lg text-center">
                                        <div className="text-green-600 text-lg font-bold">{importResults.successCount || 0}</div>
                                        <div className="text-green-700 text-[10px] uppercase font-bold">Successful</div>
                                    </div>
                                    <div className="flex-1 p-3 bg-red-50 rounded-lg text-center">
                                        <div className="text-red-600 text-lg font-bold">{importResults.failureCount || 0}</div>
                                        <div className="text-red-700 text-[10px] uppercase font-bold">Failed</div>
                                    </div>
                                </div>
                                <div className="grid grid-cols-2 gap-3">
                                    <div className="p-3 bg-blue-50 rounded-lg text-center">
                                        <div className="text-blue-600 text-lg font-bold">{importResults.createdCount || 0}</div>
                                        <div className="text-blue-700 text-[10px] uppercase font-bold">Created</div>
                                    </div>
                                    <div className="p-3 bg-amber-50 rounded-lg text-center">
                                        <div className="text-amber-600 text-lg font-bold">{importResults.updatedCount || 0}</div>
                                        <div className="text-amber-700 text-[10px] uppercase font-bold">Updated</div>
                                    </div>
                                </div>

                                {importResults.errors && importResults.errors.length > 0 && (
                                    <div className="border border-red-100 rounded overflow-hidden">
                                        <div className="bg-red-50 px-3 py-1.5 text-[10px] font-bold text-red-600 uppercase tracking-widest">Error Details</div>
                                        <div className="max-h-[150px] overflow-y-auto">
                                            <table className="w-full text-left text-[11px]">
                                                <thead className="bg-white sticky top-0 border-b">
                                                    <tr>
                                                        <th className="px-3 py-1.5">Row</th>
                                                        <th className="px-3 py-1.5">Issue</th>
                                                    </tr>
                                                </thead>
                                                <tbody>
                                                    {importResults.errors.map((e, idx) => (
                                                        <tr key={idx} className="border-b last:border-0">
                                                            <td className="px-3 py-1 font-bold text-gray-500">{e.row}</td>
                                                            <td className="px-3 py-1 text-red-500">{e.message}</td>
                                                        </tr>
                                                    ))}
                                                </tbody>
                                            </table>
                                        </div>
                                    </div>
                                )}
                                <Button block onClick={() => { setImportResults(null); setFileList([]); }}>Upload New File</Button>
                            </div>
                        )}

                        {!importResults && (
                            <>
                                {/* Zone Reference Table */}
                                <div className="border border-gray-100 rounded-lg overflow-hidden">
                                    <div className="bg-gray-50 px-3 py-2 border-b text-[10px] font-black uppercase text-gray-500 tracking-widest flex justify-between items-center">
                                        Zone ID Reference
                                        <span className="font-normal text-[9px] lowercase italic">(Use these IDs in your csv)</span>
                                    </div>
                                    <div className="max-h-[120px] overflow-y-auto custom-scrollbar">
                                        <table className="w-full text-left text-[11px]">
                                            <thead className="bg-white sticky top-0 border-b">
                                                <tr>
                                                    <th className="px-3 py-1.5 font-bold">Zone ID</th>
                                                    <th className="px-3 py-1.5 font-bold">Zone Name</th>
                                                    <th className="px-3 py-1.5 font-bold">Warehouse</th>
                                                </tr>
                                            </thead>
                                            <tbody className="divide-y divide-gray-50">
                                                {zones.map(z => (
                                                    <tr key={z.id} className="hover:bg-gray-50">
                                                        <td className="px-3 py-1 font-black text-blue-600">{z.id}</td>
                                                        <td className="px-3 py-1">{z.name} ({z.code})</td>
                                                        <td className="px-3 py-1 text-gray-400">{z.Warehouse?.name || '—'}</td>
                                                    </tr>
                                                ))}
                                            </tbody>
                                        </table>
                                    </div>
                                </div>

                                <Upload
                                    beforeUpload={(file) => {
                                        setFileList([file]);
                                        return false;
                                    }}
                                    onRemove={() => setFileList([])}
                                    fileList={fileList}
                                    accept=".csv"
                                    maxCount={1}
                                >
                                    <Button icon={<UploadOutlined />} className="w-full h-24 flex flex-col items-center justify-center gap-2 border-dashed">
                                        <span>Click or Drag CSV file here</span>
                                        <span className="text-gray-400 text-xs font-normal">Support only .csv files</span>
                                    </Button>
                                </Upload>
                            </>
                        )}
                    </div>
                </Modal>

                <Modal
                    title={viewMode ? 'View Location' : selectedLocation ? 'Edit Location' : 'Add Location'}
                    open={modalOpen}
                    onCancel={() => { setModalOpen(false); setSelectedLocation(null); setViewMode(false); }}
                    onOk={viewMode ? undefined : () => form.submit()}
                    okButtonProps={{ className: 'bg-blue-600 border-blue-600', loading: saving }}
                    footer={viewMode ? [<Button key="close" onClick={() => { setModalOpen(false); setViewMode(false); setSelectedLocation(null); }}>Close</Button>] : undefined}
                    width={620}
                >
                    {viewMode && selectedLocation ? (
                        <div className="pt-2 space-y-4">
                            <div><div className="text-gray-500 text-sm font-normal mb-1">Location Name</div><div className="text-gray-900">{selectedLocation.name ?? '—'}</div></div>
                            <div><div className="text-gray-500 text-sm font-normal mb-1">Warehouse</div><div className="text-gray-900">{selectedLocation.Zone?.Warehouse ? `${selectedLocation.Zone.Warehouse.name} (${selectedLocation.Zone.Warehouse.code})` : '—'}</div></div>
                            <div className="grid grid-cols-4 gap-3">
                                <div><div className="text-gray-500 text-sm font-normal mb-1">Aisle</div><div className="text-gray-900">{selectedLocation.aisle ?? '—'}</div></div>
                                <div><div className="text-gray-500 text-sm font-normal mb-1">Rack</div><div className="text-gray-900">{selectedLocation.rack ?? '—'}</div></div>
                                <div><div className="text-gray-500 text-sm font-normal mb-1">Shelf</div><div className="text-gray-900">{selectedLocation.shelf ?? '—'}</div></div>
                                <div><div className="text-gray-500 text-sm font-normal mb-1">Bin</div><div className="text-gray-900">{selectedLocation.bin ?? '—'}</div></div>
                            </div>
                            <div><div className="text-gray-500 text-sm font-normal mb-1">Location Type</div><div className="text-gray-900">{selectedLocation.locationType ? (LOCATION_TYPE_LABELS[selectedLocation.locationType] || selectedLocation.locationType) : '—'}</div></div>
                            <div><div className="text-gray-500 text-sm font-normal mb-1">Pick Sequence</div><div className="text-gray-900">{selectedLocation.pickSequence != null ? selectedLocation.pickSequence : '—'}</div></div>
                            <div><div className="text-gray-500 text-sm font-normal mb-1">Max Weight (kg)</div><div className="text-gray-900">{selectedLocation.maxWeight != null ? selectedLocation.maxWeight : '—'}</div></div>
                            <div><div className="text-gray-500 text-sm font-normal mb-1">Heat Sensitive Location</div><div className="text-gray-900">{selectedLocation.heatSensitive ?? '—'}</div></div>
                        </div>
                    ) : (
                        <Form form={form} layout="vertical" onFinish={handleSubmit} className="pt-4">
                            <div className="grid grid-cols-2 gap-4">
                                <Form.Item label="Warehouse" name="warehouseId" rules={[{ required: true, message: 'Select warehouse' }]}>
                                    <Select placeholder="Select warehouse" className="rounded-lg" allowClear onChange={() => form.setFieldValue('zoneId', undefined)}>
                                        {(Array.isArray(warehouses) ? warehouses : []).map(wh => <Option key={wh.id} value={wh.id}>{wh.name} ({wh.code})</Option>)}
                                    </Select>
                                </Form.Item>
                                <Form.Item label="Zone" name="zoneId" rules={[{ required: true, message: 'Select zone' }]}>
                                    <Select placeholder="Select zone (choose warehouse first)" className="rounded-lg" disabled={!selectedWarehouseId} allowClear>
                                        {zonesByWarehouse.map(z => <Option key={z.id} value={z.id}>{z.name} ({z.code})</Option>)}
                                    </Select>
                                </Form.Item>
                            </div>
                            <div className="grid grid-cols-4 gap-3">
                                <Form.Item label="Aisle" name="aisle"><Input placeholder="Aisle" className="rounded-lg" /></Form.Item>
                                <Form.Item label="Rack" name="rack"><Input placeholder="Rack" className="rounded-lg" /></Form.Item>
                                <Form.Item label="Shelf" name="shelf"><Input placeholder="Shelf" className="rounded-lg" /></Form.Item>
                                <Form.Item label="Bin" name="bin"><Input placeholder="Bin" className="rounded-lg" /></Form.Item>
                            </div>
                            <Form.Item label="Manual Name (Overwrites Aisle+Rack parts)" name="name">
                                <Input placeholder="Leave blank to use Aisle+Rack+Shelf+Bin" className="rounded-lg" />
                            </Form.Item>
                            <Form.Item label="Location Type" name="locationType">
                                <Select placeholder="Select location type" className="rounded-lg" allowClear>
                                    <Option value="PICK">Pick</Option>
                                    <Option value="BULK">Bulk</Option>
                                    <Option value="QUARANTINE">Quarantine</Option>
                                    <Option value="STAGING">Staging</Option>
                                </Select>
                            </Form.Item>
                            <div className="grid grid-cols-2 gap-4">
                                <Form.Item label="Pick Sequence" name="pickSequence">
                                    <InputNumber placeholder="Sequence" className="w-full rounded-lg" min={0} />
                                </Form.Item>
                                <Form.Item label="Max Weight (kg)" name="maxWeight">
                                    <InputNumber placeholder="Max weight" className="w-full rounded-lg" min={0} step={0.01} />
                                </Form.Item>
                            </div>
                            <Form.Item label="Heat Sensitive Location" name="heatSensitive">
                                <Select placeholder="Select" className="rounded-lg" allowClear>
                                    <Option value="yes">Yes</Option>
                                    <Option value="no">No</Option>
                                </Select>
                            </Form.Item>
                        </Form>
                    )}
                </Modal>
            </div>
        </MainLayout>
    );
}

