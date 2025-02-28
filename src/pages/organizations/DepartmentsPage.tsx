import React, { useState } from 'react';
import { useTranslation } from 'react-i18next';
import { useParams } from 'react-router-dom';
import { useDepartments } from '../../hooks/useDepartments';
import { Department } from '../../types/database';
import {
  FolderTree,
  Plus,
  Pencil,
  Trash2,
  CheckCircle,
  XCircle,
  FileText,
} from 'lucide-react';

export function DepartmentsPage() {
  const { t } = useTranslation();
  const { organizationId } = useParams<{ organizationId: string }>();
  const {
    departments,
    loading,
    error,
    createDepartment,
    updateDepartment,
    deleteDepartment,
  } = useDepartments(organizationId);

  const [isCreating, setIsCreating] = useState(false);
  const [editingId, setEditingId] = useState<string | null>(null);
  const [formData, setFormData] = useState({
    name: '',
    description: '',
    is_active: true,
  });

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    try {
      if (editingId) {
        await updateDepartment(editingId, formData);
        setEditingId(null);
      } else {
        await createDepartment({
          ...formData,
          organization_id: organizationId!,
        });
        setIsCreating(false);
      }
      setFormData({ name: '', description: '', is_active: true });
    } catch (error) {
      console.error('Error saving department:', error);
    }
  };

  const handleEdit = (dept: Department) => {
    setEditingId(dept.id);
    setFormData({
      name: dept.name,
      description: dept.description || '',
      is_active: dept.is_active,
    });
  };

  const handleDelete = async (id: string) => {
    if (window.confirm(t('common.confirmDelete'))) {
      try {
        await deleteDepartment(id);
      } catch (error) {
        console.error('Error deleting department:', error);
      }
    }
  };

  if (loading) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-primary"></div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="p-4 text-destructive bg-destructive/10 rounded-lg">
        {error}
      </div>
    );
  }

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <h1 className="text-2xl font-bold">{t('nav.departments')}</h1>
        {!isCreating && (
          <button
            onClick={() => setIsCreating(true)}
            className="inline-flex items-center gap-2 px-4 py-2 bg-primary text-primary-foreground rounded-md hover:bg-primary/90 transition-colors"
          >
            <Plus className="h-4 w-4" />
            {t('common.create')}
          </button>
        )}
      </div>

      {(isCreating || editingId) && (
        <form onSubmit={handleSubmit} className="bg-card p-6 rounded-lg shadow-sm space-y-4">
          <div className="space-y-2">
            <label className="text-sm font-medium">{t('common.name')}</label>
            <input
              type="text"
              value={formData.name}
              onChange={(e) => setFormData({ ...formData, name: e.target.value })}
              className="w-full px-3 py-2 rounded-md border bg-background"
              required
            />
          </div>
          <div className="space-y-2">
            <label className="text-sm font-medium">{t('common.description')}</label>
            <textarea
              value={formData.description}
              onChange={(e) => setFormData({ ...formData, description: e.target.value })}
              className="w-full px-3 py-2 rounded-md border bg-background min-h-[100px]"
            />
          </div>
          <div className="flex items-center gap-2">
            <input
              type="checkbox"
              checked={formData.is_active}
              onChange={(e) => setFormData({ ...formData, is_active: e.target.checked })}
              className="rounded border-gray-300"
            />
            <label className="text-sm font-medium">{t('common.active')}</label>
          </div>
          <div className="flex items-center gap-2">
            <button
              type="submit"
              className="px-4 py-2 bg-primary text-primary-foreground rounded-md hover:bg-primary/90 transition-colors"
            >
              {editingId ? t('common.save') : t('common.create')}
            </button>
            <button
              type="button"
              onClick={() => {
                setIsCreating(false);
                setEditingId(null);
                setFormData({ name: '', description: '', is_active: true });
              }}
              className="px-4 py-2 bg-secondary text-secondary-foreground rounded-md hover:bg-secondary/90 transition-colors"
            >
              {t('common.cancel')}
            </button>
          </div>
        </form>
      )}

      <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-3">
        {departments.map((dept) => (
          <div
            key={dept.id}
            className="bg-card p-6 rounded-lg shadow-sm space-y-4"
          >
            <div className="flex items-start justify-between">
              <div className="flex items-center gap-2">
                <FolderTree className="h-5 w-5 text-primary" />
                <h3 className="font-medium">{dept.name}</h3>
              </div>
              <div className="flex items-center gap-2">
                <button
                  onClick={() => handleEdit(dept)}
                  className="p-1 hover:bg-muted rounded-md transition-colors"
                >
                  <Pencil className="h-4 w-4" />
                </button>
                <button
                  onClick={() => handleDelete(dept.id)}
                  className="p-1 hover:bg-destructive/10 text-destructive rounded-md transition-colors"
                >
                  <Trash2 className="h-4 w-4" />
                </button>
              </div>
            </div>

            {dept.description && (
              <div className="flex items-start gap-2 text-sm text-muted-foreground">
                <FileText className="h-4 w-4 mt-1 shrink-0" />
                <p>{dept.description}</p>
              </div>
            )}

            <div className="flex items-center gap-2 text-sm">
              {dept.is_active ? (
                <div className="flex items-center gap-1 text-green-600 dark:text-green-500">
                  <CheckCircle className="h-4 w-4" />
                  {t('common.active')}
                </div>
              ) : (
                <div className="flex items-center gap-1 text-destructive">
                  <XCircle className="h-4 w-4" />
                  {t('common.inactive')}
                </div>
              )}
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}