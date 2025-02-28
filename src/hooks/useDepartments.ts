import { useState, useEffect } from 'react';
import { supabase } from '../lib/supabase';
import { Department } from '../types/database';

export function useDepartments(organizationId?: string) {
  const [departments, setDepartments] = useState<Department[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    if (organizationId) {
      fetchDepartments();
    }
  }, [organizationId]);

  async function fetchDepartments() {
    try {
      setLoading(true);
      const { data, error } = await supabase
        .from('departments')
        .select('*')
        .eq('organization_id', organizationId)
        .order('name');

      if (error) throw error;

      setDepartments(data);
    } catch (err) {
      setError(err instanceof Error ? err.message : 'An error occurred');
    } finally {
      setLoading(false);
    }
  }

  async function createDepartment(department: Omit<Department, 'id' | 'created_at' | 'updated_at'>) {
    try {
      const { data, error } = await supabase
        .from('departments')
        .insert([department])
        .select()
        .single();

      if (error) throw error;

      setDepartments(prev => [...prev, data]);
      return data;
    } catch (err) {
      throw err;
    }
  }

  async function updateDepartment(id: string, updates: Partial<Department>) {
    try {
      const { data, error } = await supabase
        .from('departments')
        .update(updates)
        .eq('id', id)
        .select()
        .single();

      if (error) throw error;

      setDepartments(prev =>
        prev.map(dept => (dept.id === id ? { ...dept, ...data } : dept))
      );
      return data;
    } catch (err) {
      throw err;
    }
  }

  async function deleteDepartment(id: string) {
    try {
      const { error } = await supabase
        .from('departments')
        .delete()
        .eq('id', id);

      if (error) throw error;

      setDepartments(prev => prev.filter(dept => dept.id !== id));
    } catch (err) {
      throw err;
    }
  }

  return {
    departments,
    loading,
    error,
    createDepartment,
    updateDepartment,
    deleteDepartment,
    refetch: fetchDepartments,
  };
}