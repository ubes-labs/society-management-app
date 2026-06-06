DO $$
BEGIN

    -- =====================================================
    -- appsociety.society
    -- =====================================================

    IF EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_schema = 'appsociety'
          AND table_name = 'society'
          AND column_name = 'createdby'
          AND data_type <> 'uuid'
    ) THEN
        ALTER TABLE appsociety.society
        ALTER COLUMN createdby TYPE uuid USING createdby::uuid;
    END IF;

    IF EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_schema = 'appsociety'
          AND table_name = 'society'
          AND column_name = 'createdby'
          AND is_nullable = 'YES'
    ) THEN
        ALTER TABLE appsociety.society
        ALTER COLUMN createdby SET NOT NULL;
    END IF;

    IF EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_schema = 'appsociety'
          AND table_name = 'society'
          AND column_name = 'updatedby'
          AND data_type <> 'uuid'
    ) THEN
        ALTER TABLE appsociety.society
        ALTER COLUMN updatedby TYPE uuid USING updatedby::uuid;
    END IF;

    IF EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_schema = 'appsociety'
          AND table_name = 'society'
          AND column_name = 'updatedby'
          AND is_nullable = 'YES'
    ) THEN
        ALTER TABLE appsociety.society
        ALTER COLUMN updatedby SET NOT NULL;
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE conname = 'fk_society_created_by'
    ) THEN
        ALTER TABLE appsociety.society
        ADD CONSTRAINT fk_society_created_by
        FOREIGN KEY (createdby)
        REFERENCES auth.users(id);
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE conname = 'fk_society_updated_by'
    ) THEN
        ALTER TABLE appsociety.society
        ADD CONSTRAINT fk_society_updated_by
        FOREIGN KEY (updatedby)
        REFERENCES auth.users(id);
    END IF;

    -- =====================================================
    -- appsociety.societylocation
    -- =====================================================

    IF EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_schema = 'appsociety'
          AND table_name = 'societylocation'
          AND column_name = 'createdby'
          AND data_type <> 'uuid'
    ) THEN
        ALTER TABLE appsociety.societylocation
        ALTER COLUMN createdby TYPE uuid USING createdby::uuid;
    END IF;

    IF EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_schema = 'appsociety'
          AND table_name = 'societylocation'
          AND column_name = 'createdby'
          AND is_nullable = 'YES'
    ) THEN
        ALTER TABLE appsociety.societylocation
        ALTER COLUMN createdby SET NOT NULL;
    END IF;

    IF EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_schema = 'appsociety'
          AND table_name = 'societylocation'
          AND column_name = 'updatedby'
          AND data_type <> 'uuid'
    ) THEN
        ALTER TABLE appsociety.societylocation
        ALTER COLUMN updatedby TYPE uuid USING updatedby::uuid;
    END IF;

    IF EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_schema = 'appsociety'
          AND table_name = 'societylocation'
          AND column_name = 'updatedby'
          AND is_nullable = 'YES'
    ) THEN
        ALTER TABLE appsociety.societylocation
        ALTER COLUMN updatedby SET NOT NULL;
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE conname = 'fk_society_location_created_by'
    ) THEN
        ALTER TABLE appsociety.societylocation
        ADD CONSTRAINT fk_society_location_created_by
        FOREIGN KEY (createdby)
        REFERENCES auth.users(id);
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE conname = 'fk_society_location_updated_by'
    ) THEN
        ALTER TABLE appsociety.societylocation
        ADD CONSTRAINT fk_society_location_updated_by
        FOREIGN KEY (updatedby)
        REFERENCES auth.users(id);
    END IF;

    -- =====================================================
    -- appsociety.societylocationunit
    -- =====================================================

    IF EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_schema = 'appsociety'
          AND table_name = 'societylocationunit'
          AND column_name = 'createdby'
          AND data_type <> 'uuid'
    ) THEN
        ALTER TABLE appsociety.societylocationunit
        ALTER COLUMN createdby TYPE uuid USING createdby::uuid;
    END IF;

    IF EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_schema = 'appsociety'
          AND table_name = 'societylocationunit'
          AND column_name = 'createdby'
          AND is_nullable = 'YES'
    ) THEN
        ALTER TABLE appsociety.societylocationunit
        ALTER COLUMN createdby SET NOT NULL;
    END IF;

    IF EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_schema = 'appsociety'
          AND table_name = 'societylocationunit'
          AND column_name = 'updatedby'
          AND data_type <> 'uuid'
    ) THEN
        ALTER TABLE appsociety.societylocationunit
        ALTER COLUMN updatedby TYPE uuid USING updatedby::uuid;
    END IF;

    IF EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_schema = 'appsociety'
          AND table_name = 'societylocationunit'
          AND column_name = 'updatedby'
          AND is_nullable = 'YES'
    ) THEN
        ALTER TABLE appsociety.societylocationunit
        ALTER COLUMN updatedby SET NOT NULL;
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE conname = 'fk_society_location_unit_created_by'
    ) THEN
        ALTER TABLE appsociety.societylocationunit
        ADD CONSTRAINT fk_society_location_unit_created_by
        FOREIGN KEY (createdby)
        REFERENCES auth.users(id);
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE conname = 'fk_society_location_unit_updated_by'
    ) THEN
        ALTER TABLE appsociety.societylocationunit
        ADD CONSTRAINT fk_society_location_unit_updated_by
        FOREIGN KEY (updatedby)
        REFERENCES auth.users(id);
    END IF;

    -- =====================================================
    -- appsociety.apartment
    -- =====================================================

    IF EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_schema = 'appsociety'
          AND table_name = 'apartment'
          AND column_name = 'createdby'
          AND data_type <> 'uuid'
    ) THEN
        ALTER TABLE appsociety.apartment
        ALTER COLUMN createdby TYPE uuid USING createdby::uuid;
    END IF;

    IF EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_schema = 'appsociety'
          AND table_name = 'apartment'
          AND column_name = 'createdby'
          AND is_nullable = 'YES'
    ) THEN
        ALTER TABLE appsociety.apartment
        ALTER COLUMN createdby SET NOT NULL;
    END IF;

    IF EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_schema = 'appsociety'
          AND table_name = 'apartment'
          AND column_name = 'updatedby'
          AND data_type <> 'uuid'
    ) THEN
        ALTER TABLE appsociety.apartment
        ALTER COLUMN updatedby TYPE uuid USING updatedby::uuid;
    END IF;

    IF EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_schema = 'appsociety'
          AND table_name = 'apartment'
          AND column_name = 'updatedby'
          AND is_nullable = 'YES'
    ) THEN
        ALTER TABLE appsociety.apartment
        ALTER COLUMN updatedby SET NOT NULL;
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE conname = 'fk_apartment_created_by'
    ) THEN
        ALTER TABLE appsociety.apartment
        ADD CONSTRAINT fk_apartment_created_by
        FOREIGN KEY (createdby)
        REFERENCES auth.users(id);
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE conname = 'fk_apartment_updated_by'
    ) THEN
        ALTER TABLE appsociety.apartment
        ADD CONSTRAINT fk_apartment_updated_by
        FOREIGN KEY (updatedby)
        REFERENCES auth.users(id);
    END IF;

    -- =====================================================
    -- appadmin.societylocationuserrolepermission
    -- =====================================================

    IF EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_schema = 'appadmin'
          AND table_name = 'societylocationuserrolepermission'
          AND column_name = 'userid'
          AND data_type <> 'uuid'
    ) THEN
        ALTER TABLE appadmin.societylocationuserrolepermission
        ALTER COLUMN userid TYPE uuid USING userid::uuid;
    END IF;

    IF EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_schema = 'appadmin'
          AND table_name = 'societylocationuserrolepermission'
          AND column_name = 'userid'
          AND is_nullable = 'YES'
    ) THEN
        ALTER TABLE appadmin.societylocationuserrolepermission
        ALTER COLUMN userid SET NOT NULL;
    END IF;

    IF EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_schema = 'appadmin'
          AND table_name = 'societylocationuserrolepermission'
          AND column_name = 'createdby'
          AND data_type <> 'uuid'
    ) THEN
        ALTER TABLE appadmin.societylocationuserrolepermission
        ALTER COLUMN createdby TYPE uuid USING createdby::uuid;
    END IF;

    IF EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_schema = 'appadmin'
          AND table_name = 'societylocationuserrolepermission'
          AND column_name = 'createdby'
          AND is_nullable = 'YES'
    ) THEN
        ALTER TABLE appadmin.societylocationuserrolepermission
        ALTER COLUMN createdby SET NOT NULL;
    END IF;

    IF EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_schema = 'appadmin'
          AND table_name = 'societylocationuserrolepermission'
          AND column_name = 'updatedby'
          AND data_type <> 'uuid'
    ) THEN
        ALTER TABLE appadmin.societylocationuserrolepermission
        ALTER COLUMN updatedby TYPE uuid USING updatedby::uuid;
    END IF;

    IF EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_schema = 'appadmin'
          AND table_name = 'societylocationuserrolepermission'
          AND column_name = 'updatedby'
          AND is_nullable = 'YES'
    ) THEN
        ALTER TABLE appadmin.societylocationuserrolepermission
        ALTER COLUMN updatedby SET NOT NULL;
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE conname = 'fk_user_role_permission_user'
    ) THEN
        ALTER TABLE appadmin.societylocationuserrolepermission
        ADD CONSTRAINT fk_user_role_permission_user
        FOREIGN KEY (userid)
        REFERENCES auth.users(id)
        ON DELETE CASCADE;
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE conname = 'fk_user_role_permission_created_by'
    ) THEN
        ALTER TABLE appadmin.societylocationuserrolepermission
        ADD CONSTRAINT fk_user_role_permission_created_by
        FOREIGN KEY (createdby)
        REFERENCES auth.users(id);
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE conname = 'fk_user_role_permission_updated_by'
    ) THEN
        ALTER TABLE appadmin.societylocationuserrolepermission
        ADD CONSTRAINT fk_user_role_permission_updated_by
        FOREIGN KEY (updatedby)
        REFERENCES auth.users(id);
    END IF;

END $$;