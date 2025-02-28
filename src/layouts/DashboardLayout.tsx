import React from 'react';
import { Routes, Route, Link, useNavigate } from 'react-router-dom';
import { useTranslation } from 'react-i18next';
import { useAuth } from '../contexts/AuthContext';
import { useEmployee } from '../hooks/useEmployee';
import { OrganizationsPage } from '../pages/organizations/OrganizationsPage';
import { DepartmentsPage } from '../pages/organizations/DepartmentsPage';
import { SettingsPage } from '../pages/settings/SettingsPage';
import {
  Building2,
  LayoutDashboard,
  Users,
  Building,
  Settings,
  LogOut,
  Sun,
  Moon,
} from 'lucide-react';

import { cn } from '../lib/utils';

export function DashboardLayout() {
  const { t } = useTranslation();
  const { signOut } = useAuth();
  const { employee, loading: employeeLoading } = useEmployee();
  const { user } = useAuth();
  const navigate = useNavigate();
  const [isDark, setIsDark] = React.useState(
    window.matchMedia('(prefers-color-scheme: dark)').matches
  );

  React.useEffect(() => {
    document.documentElement.classList.toggle('dark', isDark);
  }, [isDark]);

  const handleSignOut = async () => {
    try {
      await signOut();
      navigate('/signin');
    } catch (error) {
      console.error('Error signing out:', error);
    }
  };

  return (
    <div className="min-h-screen bg-background">
      {/* Sidebar */}
      <div className="fixed inset-y-0 left-0 w-64 bg-card border-r border-border">
        <div className="p-6">
          <div className="flex items-center gap-2 mb-8">
            <Building2 className="h-6 w-6 text-primary" />
            <span className="text-xl font-bold">OrganizeHub</span>
          
          <div className="mb-6 px-3 py-2 bg-muted/50 rounded-lg">
            {employeeLoading ? (
              <div className="h-6 w-32 animate-pulse bg-muted rounded" />
            ) : employee ? (
              <div className="space-y-1">
                <p className="font-medium">
                  {employee.first_name} {employee.last_name}
                </p>
                <p className="text-sm text-muted-foreground capitalize">
                  {employee.role.replace('_', ' ')}
                </p>
              </div>
            ) : null}
          </div>
          </div>

          <nav className="space-y-1">
            <Link
              to="/dashboard"
              className="flex items-center gap-2 px-3 py-2 text-sm rounded-md hover:bg-muted/50 transition-colors"
            >
              <LayoutDashboard className="h-4 w-4" />
              {t('nav.dashboard')}
            </Link>

            <Link
              to="/dashboard/employees"
              className="flex items-center gap-2 px-3 py-2 text-sm rounded-md hover:bg-muted/50 transition-colors"
            >
              <Users className="h-4 w-4" />
              {t('nav.employees')}
            </Link>

            <Link
              to="/dashboard/organizations"
              className="flex items-center gap-2 px-3 py-2 text-sm rounded-md hover:bg-muted/50 transition-colors"
            >
              <Building className="h-4 w-4" />
              {t('nav.organizations')}
            </Link>

            <Link
              to="/dashboard/settings"
              className="flex items-center gap-2 px-3 py-2 text-sm rounded-md hover:bg-muted/50 transition-colors"
            >
              <Settings className="h-4 w-4" />
              {t('nav.settings')}
            </Link>
          </nav>
        </div>

        <div className="absolute bottom-0 left-0 right-0 p-4 border-t border-border">
          <div className="flex items-center justify-between mb-4">
            <button
              onClick={() => setIsDark(!isDark)}
              className="p-2 hover:bg-muted rounded-md transition-colors"
            >
              {isDark ? (
                <Sun className="h-4 w-4" />
              ) : (
                <Moon className="h-4 w-4" />
              )}
            </button>
          </div>
          <button
            onClick={handleSignOut}
            className="flex items-center gap-2 w-full px-3 py-2 text-sm text-destructive hover:bg-destructive/10 rounded-md transition-colors"
          >
            <LogOut className="h-4 w-4" />
            {t('auth.signOut')}
          </button>
        </div>
      </div>

      {/* Main content */}
      <div className="pl-64">
        <header className="bg-card border-b border-border">
          <div className="container px-8 py-4">
            <div className="flex items-center justify-between">
              <h1 className="text-2xl font-semibold">
                {employeeLoading ? (
                  <div className="h-8 w-48 animate-pulse bg-muted rounded" />
                ) : employee ? (
                  <>
                    {t('common.welcome')}, {employee.first_name} {employee.last_name}!
                  </>
                ) : (
                  <span>
                    {t('common.welcome')}
                    {user ? '!' : ''}
                  </span>
                )}
              </h1>
              <div className="flex items-center gap-4">
                <button
                  onClick={() => setIsDark(!isDark)}
                  className="p-2 hover:bg-muted rounded-md transition-colors"
                  title={isDark ? t('common.lightMode') : t('common.darkMode')}
                >
                  {isDark ? (
                    <Sun className="h-5 w-5" />
                  ) : (
                    <Moon className="h-5 w-5" />
                  )}
                </button>
              </div>
            </div>
          </div>
        </header>
        <main className="p-8">
          <Routes>
            <Route index element={<div>Dashboard Content</div>} />
            <Route path="employees" element={<div>Employees Content</div>} />
            <Route path="organizations" element={<OrganizationsPage />} />
            <Route path="organizations/:organizationId/departments" element={<DepartmentsPage />} />
            <Route path="settings" element={<SettingsPage />} />
          </Routes>
        </main>
      </div>
    </div>
  );
}