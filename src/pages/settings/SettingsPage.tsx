import React, { useState } from 'react';
import { useTranslation } from 'react-i18next';
import { useEmployee } from '../../hooks/useEmployee';
import { User, Phone, Calendar, Mail, Building } from 'lucide-react';

export function SettingsPage() {
  const { t } = useTranslation();
  const { employee, loading, error, updateEmployee } = useEmployee();
  const [isEditing, setIsEditing] = useState(false);
  const [formData, setFormData] = useState({
    first_name: '',
    last_name: '',
    phone: '',
  });
  const [updateError, setUpdateError] = useState<string | null>(null);
  const [updateSuccess, setUpdateSuccess] = useState(false);

  React.useEffect(() => {
    if (employee) {
      setFormData({
        first_name: employee.first_name,
        last_name: employee.last_name,
        phone: employee.phone || '',
      });
    }
  }, [employee]);

  if (loading) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-primary"></div>
      </div>
    );
  }

  if (error || !employee) {
    return (
      <div className="p-4 text-destructive bg-destructive/10 rounded-lg">
        {error || 'Failed to load employee data'}
      </div>
    );
  }

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    try {
      setUpdateError(null);
      await updateEmployee(formData);
      setUpdateSuccess(true);
      setIsEditing(false);
      setTimeout(() => setUpdateSuccess(false), 3000);
    } catch (err) {
      setUpdateError(err instanceof Error ? err.message : 'Failed to update profile');
    }
  };

  return (
    <div className="max-w-2xl mx-auto space-y-6">
      <div className="flex items-center justify-between">
        <h1 className="text-2xl font-bold">{t('nav.settings')}</h1>
        {!isEditing && (
          <button
            onClick={() => setIsEditing(true)}
            className="px-4 py-2 bg-primary text-primary-foreground rounded-md hover:bg-primary/90 transition-colors"
          >
            {t('common.edit')}
          </button>
        )}
      </div>

      {updateSuccess && (
        <div className="p-4 bg-green-500/10 text-green-600 dark:text-green-400 rounded-lg">
          Profile updated successfully!
        </div>
      )}

      {updateError && (
        <div className="p-4 text-destructive bg-destructive/10 rounded-lg">
          {updateError}
        </div>
      )}

      {isEditing ? (
        <form onSubmit={handleSubmit} className="space-y-4 bg-card p-6 rounded-lg shadow-sm">
          <div className="space-y-2">
            <label className="text-sm font-medium">First Name</label>
            <div className="relative">
              <User className="absolute left-3 top-3 h-4 w-4 text-muted-foreground" />
              <input
                type="text"
                value={formData.first_name}
                onChange={(e) => setFormData({ ...formData, first_name: e.target.value })}
                className="w-full pl-9 pr-3 py-2 bg-background border rounded-md"
                required
              />
            </div>
          </div>

          <div className="space-y-2">
            <label className="text-sm font-medium">Last Name</label>
            <div className="relative">
              <User className="absolute left-3 top-3 h-4 w-4 text-muted-foreground" />
              <input
                type="text"
                value={formData.last_name}
                onChange={(e) => setFormData({ ...formData, last_name: e.target.value })}
                className="w-full pl-9 pr-3 py-2 bg-background border rounded-md"
                required
              />
            </div>
          </div>

          <div className="space-y-2">
            <label className="text-sm font-medium">Phone Number</label>
            <div className="relative">
              <Phone className="absolute left-3 top-3 h-4 w-4 text-muted-foreground" />
              <input
                type="tel"
                value={formData.phone}
                onChange={(e) => setFormData({ ...formData, phone: e.target.value })}
                className="w-full pl-9 pr-3 py-2 bg-background border rounded-md"
                placeholder="+1234567890"
              />
            </div>
          </div>

          <div className="flex items-center gap-2 pt-4">
            <button
              type="submit"
              className="px-4 py-2 bg-primary text-primary-foreground rounded-md hover:bg-primary/90 transition-colors"
            >
              {t('common.save')}
            </button>
            <button
              type="button"
              onClick={() => {
                setIsEditing(false);
                setFormData({
                  first_name: employee.first_name,
                  last_name: employee.last_name,
                  phone: employee.phone || '',
                });
              }}
              className="px-4 py-2 bg-secondary text-secondary-foreground rounded-md hover:bg-secondary/90 transition-colors"
            >
              {t('common.cancel')}
            </button>
          </div>
        </form>
      ) : (
        <div className="bg-card p-6 rounded-lg shadow-sm space-y-4">
          <div className="grid grid-cols-2 gap-4">
            <div className="space-y-2">
              <div className="text-sm text-muted-foreground">Role</div>
              <div className="flex items-center gap-2">
                <Building className="h-4 w-4 text-primary" />
                <span className="capitalize">{employee.role.replace('_', ' ')}</span>
              </div>
            </div>

            <div className="space-y-2">
              <div className="text-sm text-muted-foreground">Hire Date</div>
              <div className="flex items-center gap-2">
                <Calendar className="h-4 w-4 text-primary" />
                <span>{new Date(employee.hire_date).toLocaleDateString()}</span>
              </div>
            </div>

            <div className="space-y-2">
              <div className="text-sm text-muted-foreground">Email</div>
              <div className="flex items-center gap-2">
                <Mail className="h-4 w-4 text-primary" />
                <span>{employee.email}</span>
              </div>
            </div>

            <div className="space-y-2">
              <div className="text-sm text-muted-foreground">Phone</div>
              <div className="flex items-center gap-2">
                <Phone className="h-4 w-4 text-primary" />
                <span>{employee.phone || 'Not provided'}</span>
              </div>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}