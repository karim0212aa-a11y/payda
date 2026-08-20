const express = require('express');
const cors = require('cors');
const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors());
app.use(express.json());

// نمونه داده موقت (بعداً با دیتابیس جایگزین شود)
const mockCategories = [
    { id: 1, name_fa: "خودرو", slug: "auto-services", requires_pro_verification: true },
    { id: 2, name_fa: "تعمیرات موبایل", slug: "mobile-repair", requires_pro_verification: true }
];

// دریافت دسته‌بندی‌ها
app.get('/api/v1/categories', (req, res) => {
    res.json(mockCategories);
});

// دریافت فیلدهای یک دسته خاص
app.get('/api/v1/categories/:slug/fields', (req, res) => {
    // در نسخه واقعی از دیتابیس خوانده می‌شود
    res.json([
        { field_key: "brand", field_label_fa: "برند", field_type: "select", options: ["سامسونگ", "اپل"] },
        { field_key: "warranty", field_label_fa: "گارانتی", field_type: "boolean" }
    ]);
});

// ثبت آگهی جدید
app.post('/api/v1/ads', (req, res) => {
    const { title, category_id, attributes } = req.body;
    // اعتبارسنجی و ذخیره در دیتابیس اینجا انجام می‌شود
    console.log("New ad received:", title);
    res.status(201).json({ message: "آگهی با موفقیت ثبت شد", status: "pending_review" });
});

// پروفایل اعتماد کاربر
app.get('/api/v1/users/:id/trust-profile', (req, res) => {
    res.json({
        trust_score: 85,
        verified_purchases: 12,
        avg_rating: 4.7,
        has_business_license: true
    });
});

app.listen(PORT, () => {
    console.log(`✅ Peyda Backend running on http://localhost:${PORT}`);
});
