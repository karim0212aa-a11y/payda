-- 1. جدول کاربران با سطوح دسترسی متفاوت
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    phone VARCHAR(15) UNIQUE NOT NULL,
    full_name VARCHAR(100),
    user_type VARCHAR(20) NOT NULL CHECK (user_type IN ('personal', 'pro')), -- شخصی یا حرفه‌ای
    is_verified BOOLEAN DEFAULT FALSE, -- احراز هویت پایه
    pro_verification_status VARCHAR(20) DEFAULT 'none', -- none, pending, approved, rejected
    business_license_url TEXT, -- لینک جواز کسب (مخصوص پرو)
    created_at TIMESTAMP DEFAULT NOW()
);

-- 2. دسته‌بندی‌های عمودی (Vertical Categories)
-- فقط دسته‌هایی که قرار است MVP باشند اینجا تعریف می‌شوند
CREATE TABLE categories (
    id SERIAL PRIMARY KEY,
    slug VARCHAR(50) UNIQUE NOT NULL, -- e.g., 'auto-services', 'mobile-repair'
    name_fa VARCHAR(100) NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    requires_pro_verification BOOLEAN DEFAULT FALSE -- آیا برای ثبت آگهی در این دسته نیاز به تایید پرو است؟
);

-- 3. فیلدهای داینامیک اختصاصی هر دسته
CREATE TABLE category_fields (
    id SERIAL PRIMARY KEY,
    category_id INT REFERENCES categories(id),
    field_key VARCHAR(50) NOT NULL,
    field_label_fa VARCHAR(100) NOT NULL,
    field_type VARCHAR(20) NOT NULL, -- text, number, select, boolean, file
    is_required_for_pro BOOLEAN DEFAULT FALSE, -- اجباری بودن برای فروشندگان حرفه‌ای
    options JSONB -- مقادیر مجاز برای select
);

-- 4. آگهی‌ها با اولویت اعتماد
CREATE TABLE ads (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id),
    category_id INT REFERENCES categories(id),
    title VARCHAR(200) NOT NULL,
    description TEXT,
    price BIGINT,
    city VARCHAR(50),
    neighborhood VARCHAR(100),
    status VARCHAR(20) DEFAULT 'draft', -- draft, pending_review, active, suspended
    trust_score INT DEFAULT 0, -- امتیاز اعتماد (بر اساس تاییدیه‌ها و نظرات)
    created_at TIMESTAMP DEFAULT NOW()
);

-- 5. مشخصات فنی آگهی (EAV Model)
CREATE TABLE ad_attributes (
    ad_id UUID REFERENCES ads(id) ON DELETE CASCADE,
    field_key VARCHAR(50) NOT NULL,
    value_text TEXT,
    value_file_url TEXT, -- برای فیلدهای نوع file (مثلاً عکس گواهی اصالت)
    PRIMARY KEY (ad_id, field_key)
);

-- 6. سیستم امتیازدهی و بازخورد (Trust Engine)
CREATE TABLE reviews (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    reviewer_id UUID REFERENCES users(id),
    reviewed_user_id UUID REFERENCES users(id), -- فروشنده مورد نظر
    ad_id UUID REFERENCES ads(id),
    rating SMALLINT NOT NULL CHECK (rating BETWEEN 1 AND 5),
    comment TEXT,
    is_verified_purchase BOOLEAN DEFAULT FALSE, -- آیا معامله واقعاً انجام شده؟
    created_at TIMESTAMP DEFAULT NOW()
);

-- 7. اشتراک‌های حرفه‌ای (Monetization Core)
CREATE TABLE pro_subscriptions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id),
    plan_type VARCHAR(20) NOT NULL, -- silver, gold, platinum
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    max_ads_limit INT NOT NULL,
    monthly_bumps_remaining INT NOT NULL,
    is_active BOOLEAN DEFAULT TRUE
);
