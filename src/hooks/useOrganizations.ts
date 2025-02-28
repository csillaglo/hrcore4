import { useState, useEffect } from 'react';
import { supabase } from '../lib/supabase';
import { Organization } from '../types/database';

export function useOrganizations() {
  const [organizations, setOrganizations] = useState<Organization[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    fetchOrganizations();
  }, []);

  async function fetchOrganizations() {
    try {
      setLoading(true);
      // Get all organizations - policies will handle access control
      const { data, error } = await supabase
        .from('organizations')
        .select('*')
        .order('name');

      if (error) throw error;
      console.log('Organizations fetched:', data?.length);
      setOrganizations(data || []);
    } catch (err) {
      setError(err instanceof Error ? err.message : 'An error occurred');
    } finally {
      setLoading(false);
    }
  }

  async function createOrganization(organization: Omit<Organization, 'id' | 'created_at' | 'updated_at'>) {
    try {
      const { data, error } = await supabase
        .from('organizations')
        .insert([organization])
        .select()
        .single();

      if (error) throw error;

      setOrganizations(prev => [...prev, data]);
      return data;
    } catch (err) {
      throw err;
    }
  }

  async function updateOrganization(id: string, updates: Partial<Organization>) {
    try {
      const { data, error } = await supabase
        .from('organizations')
        .update(updates)
        .eq('id', id)
        .select()
        .single();

      if (error) throw error;

      setOrganizations(prev =>
        prev.map(org => (org.id === id ? { ...org, ...data } : org))
      );
      return data;
    } catch (err) {
      throw err;
    }
  }

  async function deleteOrganization(id: string) {
    try {
      const { error } = await supabase
        .from('organizations')
        .delete()
        .eq('id', id);

      if (error) throw error;

      setOrganizations(prev => prev.filter(org => org.id !== id));
    } catch (err) {
      throw err;
    }
  }

  return {
    organizations,
    loading,
    error,
    createOrganization,
    updateOrganization,
    deleteOrganization,
    refetch: fetchOrganizations,
  };
}