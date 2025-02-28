import { useState, useEffect } from 'react';
import { supabase } from '../lib/supabase';
import { useAuth } from '../contexts/AuthContext';

export interface Employee {
  first_name: string;
  last_name: string;
  email: string;
  phone: string | null;
  role: string;
  organization_id: string;
  hire_date: string;
  is_active: boolean;
}

interface EmployeeUpdate {
  first_name?: string;
  last_name?: string;
  phone?: string | null;
}

export function useEmployee() {
  const { user } = useAuth();
  const [employee, setEmployee] = useState<Employee | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    if (user) {
      fetchEmployee();
    } else {
      setEmployee(null);
      setLoading(false);
    }
  }, [user]);

  async function fetchEmployee() {
    try {
      setLoading(true);
      console.log('Attempting to fetch employee data for user:', user?.id);

      if (!user?.id) {
        console.log('No user ID available, skipping fetch');
        setEmployee(null);
        return;
      }

      const { data, error } = await supabase
        .from('employees')
        .select('first_name, last_name, email, phone, role, organization_id, hire_date, is_active')
        .eq('id', user?.id)
        .single();

      if (error) {
        if (error.code === 'PGRST116' || error.code === 'PGRST104') {
          // No data found
          console.log('No employee record found for user:', user.id);
          setEmployee(null);
          return;
        }
        console.error('Supabase error fetching employee:', {
          code: error.code,
          message: error.message,
          details: error.details
        });
        throw error;
      }

      console.log('Employee data received:', {
        id: user.id,
        firstName: data.first_name,
        lastName: data.last_name,
        role: data.role,
        organizationId: data.organization_id
      });
      setEmployee(data);
    } catch (err) {
      console.error('Error fetching employee:', err);
      setError(err instanceof Error ? err.message : 'An error occurred');
      setEmployee(null);
    } finally {
      setLoading(false);
    }
  }

  async function updateEmployee(updates: EmployeeUpdate) {
    try {
      if (!user?.id) {
        throw new Error('No authenticated user');
      }

      const { data, error } = await supabase
        .from('employees')
        .update(updates)
        .eq('id', user.id)
        .select()
        .single();

      if (error) {
        console.error('Error updating employee:', error);
        throw error;
      }

      console.log('Employee updated successfully:', data);
      setEmployee(data);
      return data;
    } catch (err) {
      console.error('Failed to update employee:', err);
      throw err;
    }
  }

  return { employee, loading, error, refetch: fetchEmployee, updateEmployee };
}