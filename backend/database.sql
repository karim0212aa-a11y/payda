-- جدول کاربران با سطوح دسترسی
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    phone VARCHAR(15) UNIQUE NOT NULL,
    full_name VARCHAR(100),
    user_type VARCHAR(20) NOT NULL CHECK (user_type IN ('personal', 'pro')),
    is_verified BOOLEAN DEFAULT FALSE,
    pro_verification_status VARCHAR(20) DEFAULT 'none',
    business_license_url TEXT,
    created_at TIMESTAMP DEFAULT NOW()
);

-- دسته‌بندی‌های عمودی
CREATE TABLE categories (
    id SERIAL PRIMARY KEY,
    slug VARCHAR(50) UNIQUE NOT NULL,
    name_fa VARCHAR(100) NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    requires_pro_verification BOOLEAN DEFAULT FALSE
);

-- فیلدهای داینامیک اختصاصی
CREATE TABLE category_fields (
    id SERIAL PRIMARY KEY,
    category_id INT REFERENCES categories(id),
    field_key VARCHAR(50) NOT NULL,
    field_label_fa VARCHAR(100) NOT NULL,
    field_type VARCHAR(20) NOT NULL,
    is_required_for_pro BOOLEAN DEFAULT FALSE,
    options JSONB
);

-- آگهی‌ها با امتیاز اعتماد
CREATE TABLE ads (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id),
    category_id INT REFERENCES categories(id),
    title VARCHAR(200) NOT NULL,
    description TEXT,
    price BIGINT,
    city VARCHAR(50),
    neighborhood VARCHAR(100),
    status VARCHAR(20) DEFAULT 'draft',
    trust_score INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT NOW()
);

-- مشخصات فنی (EAV)
CREATE TABLE ad_attributes (
    ad_id UUID REFERENCES ads(id) ON DELETE CASCADE,
    field_key VARCHAR(50) NOT NULL,
    value_text TEXT,
    value_file_url TEXT,
    PRIMARY KEY (ad_id, field_key)
);

-- سیستم بازخورد و اعتماد
CREATE TABLE reviews (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    reviewer_id UUID REFERENCES users(id),
    reviewed_user_id UUID REFERENCES users(id),
    ad_id UUID REFERENCES ads(id),
    rating SMALLINT NOT NULL CHECK (rating BETWEEN 1 AND 5),
    comment TEXT,
    is_verified_purchase BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT NOW()
);

-- اشتراک‌های حرفه‌ای
CREATE TABLE pro_subscriptions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id),
    plan_type VARCHAR(20) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    max_ads_limit INT NOT NULL,
    monthly_bumps_remaining INT NOT NULL,
    is_active BOOLEAN DEFAULT TRUE
);
