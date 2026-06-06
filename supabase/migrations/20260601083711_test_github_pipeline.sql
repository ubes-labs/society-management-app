CREATE TABLE IF NOT EXISTS public.test_github_pipeline (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

INSERT INTO public.test_github_pipeline (name) VALUES ('Initial pipeline dummy test data');