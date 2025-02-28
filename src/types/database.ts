export interface Organization {
  id: string;
  name: string;
  created_at: string;
  updated_at: string;
  is_active: boolean;
  logo_url: string | null;
  website: string | null;
  address: string | null;
}

export interface Department {
  id: string;
  organization_id: string;
  name: string;
  created_at: string;
  updated_at: string;
  is_active: boolean;
  description: string | null;
}