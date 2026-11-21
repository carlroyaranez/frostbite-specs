-- Frostbite MVP full schema snapshot v1.0.0
-- Target: Supabase PostgreSQL. Safe to run repeatedly against this snapshot.
-- The Laravel API is the only application data gateway. Do not expose server `id`
-- values in API responses or sync payloads. Client relationships use `*_uuid` only.
-- `id` is a server-local identity/index key; `uuid` is the portable row identity.
--
-- This snapshot includes v1.0.1 hardening (immutable financial records, strict RLS).
-- The MVP requires network access and does not implement offline writes. 
-- Foreign keys are therefore enforced in PostgreSQL.

BEGIN;

-- ==========================================
-- 1. Core Identity & Profiles
-- ==========================================

CREATE TABLE IF NOT EXISTS public.profiles (
    id                bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    uuid              uuid NOT NULL DEFAULT gen_random_uuid(),
    auth_user_uuid    uuid NOT NULL,
    display_name      text,
    created_by        uuid,
    created_at        timestamptz NOT NULL DEFAULT now(),
    updated_at        timestamptz NOT NULL DEFAULT now(),
    archived_at       timestamptz,
    CONSTRAINT profiles_uuid_key UNIQUE (uuid),
    CONSTRAINT profiles_auth_user_uuid_key UNIQUE (auth_user_uuid),
    CONSTRAINT profiles_display_name_nonempty CHECK (display_name IS NULL OR length(btrim(display_name)) > 0),
    CONSTRAINT profiles_auth_user_fk FOREIGN KEY (auth_user_uuid)
        REFERENCES auth.users (id) ON DELETE RESTRICT
);

CREATE TABLE IF NOT EXISTS public.system_admins (
    id                bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    uuid              uuid NOT NULL DEFAULT gen_random_uuid(),
    profile_uuid      uuid NOT NULL,
    created_by        uuid,
    created_at        timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT system_admins_uuid_key UNIQUE (uuid),
    CONSTRAINT system_admins_profile_uuid_key UNIQUE (profile_uuid),
    CONSTRAINT system_admins_profile_fk FOREIGN KEY (profile_uuid)
        REFERENCES public.profiles (uuid) ON DELETE RESTRICT
);

-- ==========================================
-- 2. Organizations & Staff
-- ==========================================

CREATE TABLE IF NOT EXISTS public.organizations (
    id                bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    uuid              uuid NOT NULL DEFAULT gen_random_uuid(),
    name              text NOT NULL,
    slug              text NOT NULL,
    is_active         boolean NOT NULL DEFAULT true,
    created_by        uuid,
    created_at        timestamptz NOT NULL DEFAULT now(),
    updated_at        timestamptz NOT NULL DEFAULT now(),
    archived_at       timestamptz,
    CONSTRAINT organizations_uuid_key UNIQUE (uuid),
    CONSTRAINT organizations_name_nonempty CHECK (length(btrim(name)) > 0),
    CONSTRAINT organizations_slug_nonempty CHECK (length(btrim(slug)) > 0)
);

CREATE TABLE IF NOT EXISTS public.organization_staff (
    id                bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    uuid              uuid NOT NULL DEFAULT gen_random_uuid(),
    organization_uuid uuid NOT NULL,
    profile_uuid      uuid NOT NULL,
    role              text NOT NULL,
    created_by        uuid,
    created_at        timestamptz NOT NULL DEFAULT now(),
    updated_at        timestamptz NOT NULL DEFAULT now(),
    archived_at       timestamptz,
    CONSTRAINT organization_staff_uuid_key UNIQUE (uuid),
    CONSTRAINT organization_staff_role_check CHECK
        (role IN ('council_admin', 'treasurer', 'organization_officer')),
    CONSTRAINT organization_staff_org_fk FOREIGN KEY (organization_uuid)
        REFERENCES public.organizations (uuid) ON DELETE RESTRICT,
    CONSTRAINT organization_staff_profile_fk FOREIGN KEY (profile_uuid)
        REFERENCES public.profiles (uuid) ON DELETE RESTRICT
);

-- ==========================================
-- 3. Memberships
-- ==========================================

CREATE TABLE IF NOT EXISTS public.membership_periods (
    id                bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    uuid              uuid NOT NULL DEFAULT gen_random_uuid(),
    organization_uuid uuid NOT NULL,
    name              text NOT NULL,
    starts_on         date NOT NULL,
    ends_on           date NOT NULL,
    status            text NOT NULL DEFAULT 'draft',
    created_by        uuid,
    created_at        timestamptz NOT NULL DEFAULT now(),
    updated_at        timestamptz NOT NULL DEFAULT now(),
    archived_at       timestamptz,
    CONSTRAINT membership_periods_uuid_key UNIQUE (uuid),
    CONSTRAINT membership_periods_uuid_org_key UNIQUE (uuid, organization_uuid),
    CONSTRAINT membership_periods_dates_check CHECK (ends_on >= starts_on),
    CONSTRAINT membership_periods_status_check CHECK (status IN ('draft', 'open', 'closed')),
    CONSTRAINT membership_periods_name_nonempty CHECK (length(btrim(name)) > 0),
    CONSTRAINT membership_periods_org_fk FOREIGN KEY (organization_uuid)
        REFERENCES public.organizations (uuid) ON DELETE RESTRICT
);

CREATE TABLE IF NOT EXISTS public.memberships (
    id                    bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    uuid                  uuid NOT NULL DEFAULT gen_random_uuid(),
    organization_uuid     uuid NOT NULL,
    membership_period_uuid uuid NOT NULL,
    student_uuid          uuid NOT NULL,
    status                text NOT NULL DEFAULT 'pending',
    submitted_at          timestamptz NOT NULL DEFAULT now(),
    decided_at            timestamptz,
    decided_by            uuid,
    decision_note         text,
    created_by            uuid,
    created_at            timestamptz NOT NULL DEFAULT now(),
    updated_at            timestamptz NOT NULL DEFAULT now(),
    archived_at           timestamptz,
    CONSTRAINT memberships_uuid_key UNIQUE (uuid),
    CONSTRAINT memberships_uuid_org_key UNIQUE (uuid, organization_uuid),
    CONSTRAINT memberships_status_check CHECK (status IN ('pending', 'approved', 'rejected')),
    CONSTRAINT memberships_decision_fields_check CHECK (
        (status = 'pending' AND decided_at IS NULL AND decided_by IS NULL)
        OR (
            status IN ('approved', 'rejected')
            AND decided_at IS NOT NULL
            AND decided_by IS NOT NULL
            AND decided_at >= submitted_at
        )
    ),
    CONSTRAINT memberships_org_fk FOREIGN KEY (organization_uuid)
        REFERENCES public.organizations (uuid) ON DELETE RESTRICT,
    CONSTRAINT memberships_period_org_fk FOREIGN KEY
        (membership_period_uuid, organization_uuid)
        REFERENCES public.membership_periods (uuid, organization_uuid) ON DELETE RESTRICT,
    CONSTRAINT memberships_student_fk FOREIGN KEY (student_uuid)
        REFERENCES public.profiles (uuid) ON DELETE RESTRICT
);

-- ==========================================
-- 4. Financials (Definitions & Assessments)
-- ==========================================

CREATE TABLE IF NOT EXISTS public.fee_definitions (
    id                    bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    uuid                  uuid NOT NULL DEFAULT gen_random_uuid(),
    organization_uuid     uuid NOT NULL,
    membership_period_uuid uuid NOT NULL,
    name                  text NOT NULL,
    description           text,
    amount                numeric(12,2) NOT NULL,
    currency_code         text NOT NULL,
    created_by            uuid,
    created_at            timestamptz NOT NULL DEFAULT now(),
    updated_at            timestamptz NOT NULL DEFAULT now(),
    archived_at           timestamptz,
    CONSTRAINT fee_definitions_uuid_key UNIQUE (uuid),
    CONSTRAINT fee_definitions_uuid_org_key UNIQUE (uuid, organization_uuid),
    CONSTRAINT fee_definitions_amount_check CHECK (amount >= 0),
    CONSTRAINT fee_definitions_currency_check CHECK (currency_code ~ '^[A-Z]{3}$'),
    CONSTRAINT fee_definitions_name_nonempty CHECK (length(btrim(name)) > 0),
    CONSTRAINT fee_definitions_org_fk FOREIGN KEY (organization_uuid)
        REFERENCES public.organizations (uuid) ON DELETE RESTRICT,
    CONSTRAINT fee_definitions_period_org_fk FOREIGN KEY
        (membership_period_uuid, organization_uuid)
        REFERENCES public.membership_periods (uuid, organization_uuid) ON DELETE RESTRICT
);

CREATE TABLE IF NOT EXISTS public.fee_assessments (
    id                    bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    uuid                  uuid NOT NULL DEFAULT gen_random_uuid(),
    organization_uuid     uuid NOT NULL,
    fee_definition_uuid   uuid NOT NULL,
    membership_uuid       uuid NOT NULL,
    amount_due            numeric(12,2) NOT NULL,
    currency_code         text NOT NULL,
    assessed_by           uuid NOT NULL,
    assessed_at           timestamptz NOT NULL DEFAULT now(),
    created_at            timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT fee_assessments_uuid_key UNIQUE (uuid),
    CONSTRAINT fee_assessments_uuid_org_key UNIQUE (uuid, organization_uuid),
    CONSTRAINT fee_assessments_uuid_self_key UNIQUE (uuid, membership_uuid),
    CONSTRAINT fee_assessments_natural_key UNIQUE (fee_definition_uuid, membership_uuid),
    CONSTRAINT fee_assessments_amount_check CHECK (amount_due >= 0),
    CONSTRAINT fee_assessments_currency_check CHECK (currency_code ~ '^[A-Z]{3}$'),
    CONSTRAINT fee_assessments_fee_org_fk FOREIGN KEY (fee_definition_uuid, organization_uuid)
        REFERENCES public.fee_definitions (uuid, organization_uuid) ON DELETE RESTRICT,
    CONSTRAINT fee_assessments_membership_org_fk FOREIGN KEY (membership_uuid, organization_uuid)
        REFERENCES public.memberships (uuid, organization_uuid) ON DELETE RESTRICT
);

-- ==========================================
-- 5. Financials (Ledger)
-- ==========================================

CREATE TABLE IF NOT EXISTS public.payments (
    id                      bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    uuid                    uuid NOT NULL DEFAULT gen_random_uuid(),
    organization_uuid       uuid NOT NULL,
    fee_assessment_uuid     uuid NOT NULL,
    entry_type              text NOT NULL DEFAULT 'receipt',
    amount                  numeric(12,2) NOT NULL,
    currency_code           text NOT NULL,
    payment_channel         text NOT NULL,
    reference               text,
    received_at             timestamptz NOT NULL,
    recorded_by             uuid NOT NULL,
    reversal_of_payment_uuid uuid,
    created_at              timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT payments_uuid_key UNIQUE (uuid),
    CONSTRAINT payments_uuid_assessment_key UNIQUE (uuid, fee_assessment_uuid),
    CONSTRAINT payments_entry_type_check CHECK (entry_type IN ('receipt', 'reversal')),
    CONSTRAINT payments_entry_amount_check CHECK (
        (entry_type = 'receipt' AND amount > 0 AND reversal_of_payment_uuid IS NULL)
        OR (entry_type = 'reversal' AND amount < 0 AND reversal_of_payment_uuid IS NOT NULL)
    ),
    CONSTRAINT payments_currency_check CHECK (currency_code ~ '^[A-Z]{3}$'),
    CONSTRAINT payments_channel_nonempty CHECK (length(btrim(payment_channel)) > 0),
    CONSTRAINT payments_assessment_org_fk FOREIGN KEY (fee_assessment_uuid, organization_uuid)
        REFERENCES public.fee_assessments (uuid, organization_uuid) ON DELETE RESTRICT,
    CONSTRAINT payments_reversal_same_assessment_fk FOREIGN KEY
        (reversal_of_payment_uuid, fee_assessment_uuid)
        REFERENCES public.payments (uuid, fee_assessment_uuid) ON DELETE RESTRICT
);

CREATE TABLE IF NOT EXISTS public.audit_events (
    id                bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    uuid              uuid NOT NULL DEFAULT gen_random_uuid(),
    organization_uuid uuid,
    actor_uuid        uuid NOT NULL,
    entity_type       text NOT NULL,
    entity_uuid       uuid NOT NULL,
    action            text NOT NULL,
    before_data       jsonb,
    after_data        jsonb,
    created_at        timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT audit_events_uuid_key UNIQUE (uuid),
    CONSTRAINT audit_events_entity_type_check CHECK (
        entity_type IN ('profile', 'organization', 'organization_staff', 'membership_period',
                        'membership', 'fee_definition', 'fee_assessment', 'payment')
    ),
    CONSTRAINT audit_events_action_nonempty CHECK (length(btrim(action)) > 0),
    CONSTRAINT audit_events_org_fk FOREIGN KEY (organization_uuid)
        REFERENCES public.organizations (uuid) ON DELETE RESTRICT
);

-- ==========================================
-- 6. Indexes
-- ==========================================

CREATE UNIQUE INDEX IF NOT EXISTS organizations_live_slug_key
    ON public.organizations (slug) WHERE archived_at IS NULL;
CREATE INDEX IF NOT EXISTS organization_staff_profile_idx
    ON public.organization_staff (profile_uuid, organization_uuid) WHERE archived_at IS NULL;
CREATE UNIQUE INDEX IF NOT EXISTS organization_staff_live_role_key
    ON public.organization_staff (organization_uuid, profile_uuid, role) WHERE archived_at IS NULL;
CREATE UNIQUE INDEX IF NOT EXISTS membership_periods_live_name_key
    ON public.membership_periods (organization_uuid, name) WHERE archived_at IS NULL;
CREATE INDEX IF NOT EXISTS membership_periods_org_status_idx
    ON public.membership_periods (organization_uuid, status, starts_on);
CREATE INDEX IF NOT EXISTS memberships_student_period_idx
    ON public.memberships (student_uuid, membership_period_uuid) WHERE archived_at IS NULL;
CREATE INDEX IF NOT EXISTS memberships_org_status_idx
    ON public.memberships (organization_uuid, status, membership_period_uuid) WHERE archived_at IS NULL;
CREATE UNIQUE INDEX IF NOT EXISTS memberships_live_student_period_key
    ON public.memberships (student_uuid, organization_uuid, membership_period_uuid)
    WHERE archived_at IS NULL;
CREATE UNIQUE INDEX IF NOT EXISTS fee_definitions_live_name_period_key
    ON public.fee_definitions (organization_uuid, membership_period_uuid, name)
    WHERE archived_at IS NULL;
CREATE INDEX IF NOT EXISTS fee_definitions_period_idx
    ON public.fee_definitions (membership_period_uuid, organization_uuid) WHERE archived_at IS NULL;
CREATE INDEX IF NOT EXISTS fee_assessments_org_created_idx
    ON public.fee_assessments (organization_uuid, assessed_at DESC);
CREATE INDEX IF NOT EXISTS payments_assessment_received_idx
    ON public.payments (fee_assessment_uuid, received_at);
CREATE INDEX IF NOT EXISTS payments_org_received_idx
    ON public.payments (organization_uuid, received_at);
CREATE UNIQUE INDEX IF NOT EXISTS payments_single_reversal_key
    ON public.payments (reversal_of_payment_uuid) WHERE reversal_of_payment_uuid IS NOT NULL;
CREATE UNIQUE INDEX IF NOT EXISTS payments_reference_key
    ON public.payments (organization_uuid, payment_channel, reference, fee_assessment_uuid)
    WHERE reference IS NOT NULL AND btrim(reference) <> '';
CREATE INDEX IF NOT EXISTS audit_events_org_created_idx
    ON public.audit_events (organization_uuid, created_at DESC);
CREATE INDEX IF NOT EXISTS audit_events_entity_idx
    ON public.audit_events (entity_type, entity_uuid, created_at DESC);

-- ==========================================
-- 7. RLS Helpers (SECURITY DEFINER)
-- ==========================================

CREATE OR REPLACE FUNCTION public.current_profile_uuid()
RETURNS uuid
LANGUAGE sql STABLE SECURITY DEFINER
SET search_path = pg_catalog, public, auth
SET row_security = off
AS $$
    SELECT p.uuid FROM public.profiles AS p
    WHERE p.auth_user_uuid = auth.uid() AND p.archived_at IS NULL LIMIT 1
$$;

CREATE OR REPLACE FUNCTION public.is_system_admin()
RETURNS boolean
LANGUAGE sql STABLE SECURITY DEFINER
SET search_path = pg_catalog, public, auth
SET row_security = off
AS $$
    SELECT EXISTS (
        SELECT 1 FROM public.system_admins AS sa
        WHERE sa.profile_uuid = public.current_profile_uuid()
    )
$$;

CREATE OR REPLACE FUNCTION public.has_org_role(p_organization_uuid uuid, p_roles text[] DEFAULT NULL)
RETURNS boolean
LANGUAGE sql STABLE SECURITY DEFINER
SET search_path = pg_catalog, public, auth
SET row_security = off
AS $$
    SELECT public.is_system_admin() OR EXISTS (
        SELECT 1 FROM public.organization_staff AS os
        WHERE os.organization_uuid = p_organization_uuid
          AND os.profile_uuid = public.current_profile_uuid()
          AND os.archived_at IS NULL
          AND (p_roles IS NULL OR os.role = ANY (p_roles))
    )
$$;

CREATE OR REPLACE FUNCTION public.can_read_org(p_organization_uuid uuid)
RETURNS boolean
LANGUAGE sql STABLE SECURITY DEFINER
SET search_path = pg_catalog, public, auth
SET row_security = off
AS $$
    SELECT public.has_org_role(p_organization_uuid, NULL)
        OR EXISTS (
            SELECT 1 FROM public.memberships AS m
            WHERE m.organization_uuid = p_organization_uuid
              AND m.student_uuid = public.current_profile_uuid()
              AND m.archived_at IS NULL
        )
$$;

CREATE OR REPLACE FUNCTION public.can_view_membership(p_membership_uuid uuid, p_organization_uuid uuid)
RETURNS boolean
LANGUAGE sql STABLE SECURITY DEFINER
SET search_path = pg_catalog, public, auth
SET row_security = off
AS $$
    SELECT public.has_org_role(p_organization_uuid, NULL)
        OR EXISTS (
            SELECT 1 FROM public.memberships AS m
            WHERE m.uuid = p_membership_uuid
              AND m.organization_uuid = p_organization_uuid
              AND m.student_uuid = public.current_profile_uuid()
        )
$$;

CREATE OR REPLACE FUNCTION public.can_view_profile(p_profile_uuid uuid)
RETURNS boolean
LANGUAGE sql STABLE SECURITY DEFINER
SET search_path = pg_catalog, public, auth
SET row_security = off
AS $$
    SELECT p_profile_uuid = public.current_profile_uuid()
        OR public.is_system_admin()
        OR EXISTS (
            SELECT 1 FROM public.memberships AS m
            WHERE m.student_uuid = p_profile_uuid
              AND public.has_org_role(m.organization_uuid,
                    ARRAY['council_admin', 'treasurer', 'organization_officer']::text[])
        )
$$;

REVOKE ALL ON FUNCTION public.current_profile_uuid() FROM PUBLIC, anon;
REVOKE ALL ON FUNCTION public.is_system_admin() FROM PUBLIC, anon;
REVOKE ALL ON FUNCTION public.has_org_role(uuid, text[]) FROM PUBLIC, anon;
REVOKE ALL ON FUNCTION public.can_read_org(uuid) FROM PUBLIC, anon;
REVOKE ALL ON FUNCTION public.can_view_membership(uuid, uuid) FROM PUBLIC, anon;
REVOKE ALL ON FUNCTION public.can_view_profile(uuid) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.current_profile_uuid() TO authenticated, service_role;
GRANT EXECUTE ON FUNCTION public.is_system_admin() TO authenticated, service_role;
GRANT EXECUTE ON FUNCTION public.has_org_role(uuid, text[]) TO authenticated, service_role;
GRANT EXECUTE ON FUNCTION public.can_read_org(uuid) TO authenticated, service_role;
GRANT EXECUTE ON FUNCTION public.can_view_membership(uuid, uuid) TO authenticated, service_role;
GRANT EXECUTE ON FUNCTION public.can_view_profile(uuid) TO authenticated, service_role;

-- ==========================================
-- 8. RLS Policies
-- ==========================================

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.system_admins ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.organizations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.organization_staff ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.membership_periods ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.memberships ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.fee_definitions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.fee_assessments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.audit_events ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS profiles_read_scope ON public.profiles;
CREATE POLICY profiles_read_scope ON public.profiles FOR SELECT TO authenticated
    USING (public.can_view_profile(uuid));
DROP POLICY IF EXISTS profiles_insert_self ON public.profiles;
CREATE POLICY profiles_insert_self ON public.profiles FOR INSERT TO authenticated
    WITH CHECK (auth_user_uuid = auth.uid());
DROP POLICY IF EXISTS profiles_update_self ON public.profiles;
CREATE POLICY profiles_update_self ON public.profiles FOR UPDATE TO authenticated
    USING (auth_user_uuid = auth.uid()) WITH CHECK (auth_user_uuid = auth.uid());

DROP POLICY IF EXISTS system_admins_read_admin ON public.system_admins;
CREATE POLICY system_admins_read_admin ON public.system_admins FOR SELECT TO authenticated
    USING (public.is_system_admin());

DROP POLICY IF EXISTS organizations_read_authenticated ON public.organizations;
CREATE POLICY organizations_read_authenticated ON public.organizations FOR SELECT TO authenticated
    USING ((is_active AND archived_at IS NULL) OR public.has_org_role(uuid, NULL));
DROP POLICY IF EXISTS organizations_insert_admin ON public.organizations;
CREATE POLICY organizations_insert_admin ON public.organizations FOR INSERT TO authenticated
    WITH CHECK (public.is_system_admin());
DROP POLICY IF EXISTS organizations_update_manager ON public.organizations;
CREATE POLICY organizations_update_manager ON public.organizations FOR UPDATE TO authenticated
    USING (public.has_org_role(uuid, ARRAY['council_admin']::text[]))
    WITH CHECK (public.has_org_role(uuid, ARRAY['council_admin']::text[]));

DROP POLICY IF EXISTS organization_staff_read_scope ON public.organization_staff;
CREATE POLICY organization_staff_read_scope ON public.organization_staff FOR SELECT TO authenticated
    USING (profile_uuid = public.current_profile_uuid()
           OR public.has_org_role(organization_uuid, ARRAY['council_admin']::text[]));
DROP POLICY IF EXISTS organization_staff_insert_manager ON public.organization_staff;
CREATE POLICY organization_staff_insert_manager ON public.organization_staff FOR INSERT TO authenticated
    WITH CHECK (public.has_org_role(organization_uuid, ARRAY['council_admin']::text[]));
DROP POLICY IF EXISTS organization_staff_update_manager ON public.organization_staff;
CREATE POLICY organization_staff_update_manager ON public.organization_staff FOR UPDATE TO authenticated
    USING (public.has_org_role(organization_uuid, ARRAY['council_admin']::text[]))
    WITH CHECK (public.has_org_role(organization_uuid, ARRAY['council_admin']::text[]));

DROP POLICY IF EXISTS membership_periods_read_scope ON public.membership_periods;
CREATE POLICY membership_periods_read_scope ON public.membership_periods FOR SELECT TO authenticated
    USING ((status = 'open' AND archived_at IS NULL) OR public.can_read_org(organization_uuid));
DROP POLICY IF EXISTS membership_periods_insert_manager ON public.membership_periods;
CREATE POLICY membership_periods_insert_manager ON public.membership_periods FOR INSERT TO authenticated
    WITH CHECK (public.has_org_role(organization_uuid, ARRAY['council_admin']::text[]));
DROP POLICY IF EXISTS membership_periods_update_manager ON public.membership_periods;
CREATE POLICY membership_periods_update_manager ON public.membership_periods FOR UPDATE TO authenticated
    USING (public.has_org_role(organization_uuid, ARRAY['council_admin']::text[]))
    WITH CHECK (public.has_org_role(organization_uuid, ARRAY['council_admin']::text[]));

DROP POLICY IF EXISTS memberships_read_scope ON public.memberships;
CREATE POLICY memberships_read_scope ON public.memberships FOR SELECT TO authenticated
    USING (public.can_view_membership(uuid, organization_uuid));
DROP POLICY IF EXISTS memberships_insert_self ON public.memberships;
CREATE POLICY memberships_insert_self ON public.memberships FOR INSERT TO authenticated
    WITH CHECK (
        student_uuid = public.current_profile_uuid()
        AND status = 'pending'
        AND decided_at IS NULL
        AND decided_by IS NULL
        AND EXISTS (
            SELECT 1 FROM public.organizations AS o
            WHERE o.uuid = organization_uuid AND o.is_active AND o.archived_at IS NULL
        )
        AND EXISTS (
            SELECT 1 FROM public.membership_periods AS mp
            WHERE mp.uuid = membership_period_uuid
              AND mp.organization_uuid = organization_uuid
              AND mp.status = 'open' AND mp.archived_at IS NULL
        )
    );
DROP POLICY IF EXISTS memberships_update_officer ON public.memberships;
CREATE POLICY memberships_update_officer ON public.memberships FOR UPDATE TO authenticated
    USING (public.has_org_role(organization_uuid, ARRAY['council_admin', 'organization_officer']::text[]))
    WITH CHECK (public.has_org_role(organization_uuid, ARRAY['council_admin', 'organization_officer']::text[]));

DROP POLICY IF EXISTS fee_definitions_read_scope ON public.fee_definitions;
CREATE POLICY fee_definitions_read_scope ON public.fee_definitions FOR SELECT TO authenticated
    USING (archived_at IS NULL AND public.can_read_org(organization_uuid));
DROP POLICY IF EXISTS fee_definitions_insert_manager ON public.fee_definitions;
CREATE POLICY fee_definitions_insert_manager ON public.fee_definitions FOR INSERT TO authenticated
    WITH CHECK (public.has_org_role(organization_uuid, ARRAY['council_admin']::text[]));
DROP POLICY IF EXISTS fee_definitions_update_manager ON public.fee_definitions;
CREATE POLICY fee_definitions_update_manager ON public.fee_definitions FOR UPDATE TO authenticated
    USING (public.has_org_role(organization_uuid, ARRAY['council_admin']::text[]))
    WITH CHECK (public.has_org_role(organization_uuid, ARRAY['council_admin']::text[]));

DROP POLICY IF EXISTS fee_assessments_read_scope ON public.fee_assessments;
CREATE POLICY fee_assessments_read_scope ON public.fee_assessments FOR SELECT TO authenticated
    USING (public.can_view_membership(membership_uuid, organization_uuid));
DROP POLICY IF EXISTS fee_assessments_insert_manager ON public.fee_assessments;
CREATE POLICY fee_assessments_insert_manager ON public.fee_assessments FOR INSERT TO authenticated
    WITH CHECK (public.has_org_role(organization_uuid, ARRAY['council_admin']::text[]));

DROP POLICY IF EXISTS payments_read_scope ON public.payments;
CREATE POLICY payments_read_scope ON public.payments FOR SELECT TO authenticated
    USING (public.has_org_role(organization_uuid, ARRAY['council_admin', 'treasurer']::text[])
           OR EXISTS (
               SELECT 1 FROM public.fee_assessments AS fa
               JOIN public.memberships AS m ON m.uuid = fa.membership_uuid
               WHERE fa.uuid = fee_assessment_uuid
                 AND m.student_uuid = public.current_profile_uuid()
           ));
DROP POLICY IF EXISTS payments_insert_treasurer ON public.payments;
CREATE POLICY payments_insert_treasurer ON public.payments FOR INSERT TO authenticated
    WITH CHECK (public.has_org_role(organization_uuid, ARRAY['treasurer']::text[])
                AND recorded_by = public.current_profile_uuid());

DROP POLICY IF EXISTS audit_events_read_scope ON public.audit_events;
CREATE POLICY audit_events_read_scope ON public.audit_events FOR SELECT TO authenticated
    USING (public.is_system_admin()
           OR (organization_uuid IS NOT NULL AND public.has_org_role(organization_uuid, NULL)));

REVOKE ALL ON TABLE public.profiles, public.system_admins, public.organizations,
    public.organization_staff, public.membership_periods, public.memberships,
    public.fee_definitions, public.fee_assessments, public.payments,
    public.audit_events FROM anon, authenticated;
GRANT ALL ON TABLE public.profiles, public.system_admins, public.organizations,
    public.organization_staff, public.membership_periods, public.memberships,
    public.fee_definitions, public.fee_assessments, public.payments,
    public.audit_events TO service_role;

-- ==========================================
-- 9. Immutability & Validation Triggers
-- ==========================================

CREATE OR REPLACE FUNCTION public.reject_immutable_row_mutation()
RETURNS trigger LANGUAGE plpgsql SET search_path = pg_catalog, public AS $$
BEGIN
    RAISE EXCEPTION 'Rows in % are append-only; add a compensating record instead', TG_TABLE_NAME
        USING ERRCODE = '55000';
    RETURN NULL;
END
$$;

CREATE OR REPLACE FUNCTION public.validate_payment_entry()
RETURNS trigger LANGUAGE plpgsql SET search_path = pg_catalog, public AS $$
DECLARE
    assessment_currency text;
    original_type       text;
    original_amount     numeric(12,2);
    original_currency   text;
BEGIN
    SELECT fa.currency_code INTO assessment_currency
      FROM public.fee_assessments AS fa
     WHERE fa.uuid = NEW.fee_assessment_uuid AND fa.organization_uuid = NEW.organization_uuid;

    IF assessment_currency IS NULL OR assessment_currency <> NEW.currency_code THEN
        RAISE EXCEPTION 'Payment currency must match its assessment' USING ERRCODE = '23514';
    END IF;

    IF NEW.entry_type = 'reversal' THEN
        SELECT p.entry_type, p.amount, p.currency_code INTO original_type, original_amount, original_currency
          FROM public.payments AS p
         WHERE p.uuid = NEW.reversal_of_payment_uuid AND p.fee_assessment_uuid = NEW.fee_assessment_uuid;

        IF NOT FOUND OR original_type <> 'receipt'
           OR NEW.amount <> -original_amount OR NEW.currency_code <> original_currency THEN
            RAISE EXCEPTION 'A reversal must exactly offset one receipt in the same assessment and currency'
                USING ERRCODE = '23514';
        END IF;
    END IF;
    RETURN NEW;
END
$$;

CREATE OR REPLACE FUNCTION public.reject_membership_identity_mutation()
RETURNS trigger LANGUAGE plpgsql SET search_path = pg_catalog, public AS $$
BEGIN
    IF NEW.uuid IS DISTINCT FROM OLD.uuid
       OR NEW.organization_uuid IS DISTINCT FROM OLD.organization_uuid
       OR NEW.membership_period_uuid IS DISTINCT FROM OLD.membership_period_uuid
       OR NEW.student_uuid IS DISTINCT FROM OLD.student_uuid
       OR NEW.submitted_at IS DISTINCT FROM OLD.submitted_at
       OR NEW.created_by IS DISTINCT FROM OLD.created_by
       OR NEW.created_at IS DISTINCT FROM OLD.created_at THEN
        RAISE EXCEPTION 'Membership identity/lifecycle columns are immutable' USING ERRCODE = '55000';
    END IF;
    RETURN NEW;
END
$$;

CREATE OR REPLACE FUNCTION public.reject_fee_assessment_financial_mutation()
RETURNS trigger LANGUAGE plpgsql SET search_path = pg_catalog, public AS $$
BEGIN
    IF NEW.uuid IS DISTINCT FROM OLD.uuid
       OR NEW.organization_uuid IS DISTINCT FROM OLD.organization_uuid
       OR NEW.fee_definition_uuid IS DISTINCT FROM OLD.fee_definition_uuid
       OR NEW.membership_uuid IS DISTINCT FROM OLD.membership_uuid
       OR NEW.amount_due IS DISTINCT FROM OLD.amount_due
       OR NEW.currency_code IS DISTINCT FROM OLD.currency_code
       OR NEW.assessed_by IS DISTINCT FROM OLD.assessed_by
       OR NEW.assessed_at IS DISTINCT FROM OLD.assessed_at THEN
        RAISE EXCEPTION 'Fee assessment financial snapshot columns are immutable' USING ERRCODE = '55000';
    END IF;
    RETURN NEW;
END
$$;

CREATE OR REPLACE FUNCTION public.reject_fee_assessment_delete()
RETURNS trigger LANGUAGE plpgsql SET search_path = pg_catalog, public AS $$
BEGIN
    RAISE EXCEPTION 'Fee assessments are append-only; archive via the membership instead' USING ERRCODE = '55000';
    RETURN NULL;
END
$$;

CREATE OR REPLACE FUNCTION public.guard_staff_role_change()
RETURNS trigger LANGUAGE plpgsql SET search_path = pg_catalog, public AS $$
BEGIN
    IF NEW.role IS DISTINCT FROM OLD.role
       AND (OLD.role = 'council_admin' OR NEW.role = 'council_admin')
       AND NOT public.is_system_admin() THEN
        RAISE EXCEPTION 'Only system admins may grant or revoke council_admin' USING ERRCODE = '42501';
    END IF;

    IF NEW.uuid IS DISTINCT FROM OLD.uuid
       OR NEW.organization_uuid IS DISTINCT FROM OLD.organization_uuid
       OR NEW.profile_uuid IS DISTINCT FROM OLD.profile_uuid
       OR NEW.created_by IS DISTINCT FROM OLD.created_by
       OR NEW.created_at IS DISTINCT FROM OLD.created_at THEN
        RAISE EXCEPTION 'Organization staff identity columns are immutable' USING ERRCODE = '55000';
    END IF;
    RETURN NEW;
END
$$;

REVOKE ALL ON FUNCTION public.reject_immutable_row_mutation() FROM PUBLIC, anon, authenticated;
REVOKE ALL ON FUNCTION public.validate_payment_entry() FROM PUBLIC, anon, authenticated;
REVOKE ALL ON FUNCTION public.reject_membership_identity_mutation() FROM PUBLIC, anon, authenticated;
REVOKE ALL ON FUNCTION public.reject_fee_assessment_financial_mutation() FROM PUBLIC, anon, authenticated;
REVOKE ALL ON FUNCTION public.reject_fee_assessment_delete() FROM PUBLIC, anon, authenticated;
REVOKE ALL ON FUNCTION public.guard_staff_role_change() FROM PUBLIC, anon, authenticated;

DROP TRIGGER IF EXISTS payments_validate_entry ON public.payments;
CREATE TRIGGER payments_validate_entry BEFORE INSERT ON public.payments
    FOR EACH ROW EXECUTE FUNCTION public.validate_payment_entry();

DROP TRIGGER IF EXISTS payments_append_only ON public.payments;
CREATE TRIGGER payments_append_only BEFORE UPDATE OR DELETE ON public.payments
    FOR EACH ROW EXECUTE FUNCTION public.reject_immutable_row_mutation();

DROP TRIGGER IF EXISTS audit_events_append_only ON public.audit_events;
CREATE TRIGGER audit_events_append_only BEFORE UPDATE OR DELETE ON public.audit_events
    FOR EACH ROW EXECUTE FUNCTION public.reject_immutable_row_mutation();

DROP TRIGGER IF EXISTS memberships_identity_immutable ON public.memberships;
CREATE TRIGGER memberships_identity_immutable BEFORE UPDATE ON public.memberships
    FOR EACH ROW EXECUTE FUNCTION public.reject_membership_identity_mutation();

DROP TRIGGER IF EXISTS fee_assessments_financial_immutable ON public.fee_assessments;
CREATE TRIGGER fee_assessments_financial_immutable BEFORE UPDATE ON public.fee_assessments
    FOR EACH ROW EXECUTE FUNCTION public.reject_fee_assessment_financial_mutation();

DROP TRIGGER IF EXISTS fee_assessments_append_only ON public.fee_assessments;
CREATE TRIGGER fee_assessments_append_only BEFORE DELETE ON public.fee_assessments
    FOR EACH ROW EXECUTE FUNCTION public.reject_fee_assessment_delete();

DROP TRIGGER IF EXISTS organization_staff_role_guard ON public.organization_staff;
CREATE TRIGGER organization_staff_role_guard BEFORE UPDATE ON public.organization_staff
    FOR EACH ROW EXECUTE FUNCTION public.guard_staff_role_change();

-- ==========================================
-- 10. Documentation Comments
-- ==========================================

COMMENT ON COLUMN public.profiles.id IS 'Server-only identity/index key; never include in API or client payloads.';
COMMENT ON COLUMN public.profiles.uuid IS 'Portable row identity used by clients and all relationships.';
COMMENT ON COLUMN public.payments.id IS 'Server-only identity/index key; never include in API or client payloads.';
COMMENT ON TABLE public.payments IS 'Append-only ledger; corrections are reversal entries with negative amounts.';
COMMENT ON TABLE public.audit_events IS 'Append-only audit trail. Laravel must insert the event in the same transaction as each sensitive change.';

COMMIT;