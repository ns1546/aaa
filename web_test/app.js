// State
let history = [];
let currentFileBase64 = null;
let currentFileSizeMb = 0;
let currentFileRes = "Unknown";
let currentFileMime = "image/jpeg";

// Insert your Gemini API Key here!
const GEMINI_API_KEY = "AIzaSyBGTfEb9RlLLmOlAgDzApR0jYnuymTI7PU";

// DOM
const views = document.querySelectorAll('.view');
const fileInput = document.getElementById('file-input');
const statusText = document.getElementById('status-text');
const previewImg = document.getElementById('preview-img');
const backBtn = document.getElementById('back-btn');
const historyGrid = document.getElementById('history-grid');

function showView(id) {
    views.forEach(v => v.classList.remove('active'));
    document.getElementById(id).classList.add('active');
}

backBtn.addEventListener('click', () => {
    renderHistory();
    showView('library-view');
});

// File picker handler
fileInput.addEventListener('change', async (e) => {
    const file = e.target.files[0];
    if (!file) return;

    currentFileMime = file.type || "image/jpeg";
    currentFileSizeMb = (file.size / (1024 * 1024)).toFixed(2);

    // Auto-detect resolution via image load
    const imgObj = new Image();
    const objectUrl = URL.createObjectURL(file);
    imgObj.onload = () => {
        currentFileRes = `${imgObj.width}x${imgObj.height}`;
        URL.revokeObjectURL(objectUrl);
    };
    imgObj.src = objectUrl;

    // Convert to base64
    const reader = new FileReader();
    reader.onload = async (event) => {
        currentFileBase64 = event.target.result;
        previewImg.src = currentFileBase64;

        // Switch to scanner
        showView('analyzer-view');
        statusText.innerText = "UPLOADING PIXELS...";

        // Wait UX
        setTimeout(startAnalysis, 1000);
    };
    reader.readAsDataURL(file);
});

async function startAnalysis() {
    statusText.innerText = "NEURAL INFERENCE ACTIVE...";

    // Extract the raw base64 string without the data URI prefix for Gemini
    const rawBase64 = currentFileBase64.split(',')[1];

    const payload = {
        "contents": [
            {
                "parts": [
                    { "text": "Analyze the attached image. Respond ONLY in valid JSON format using the exact following structure: {\"smart_name\": \"...\", \"description\": \"...\", \"tags\": [\"...\", \"...\"], \"lighting_quality\": \"8/10\", \"sharpness\": \"9/10\"}. Do NOT include any markdown formatting like ```json, just output the raw JSON object." },
                    {
                        "inline_data": {
                            "mime_type": currentFileMime,
                            "data": rawBase64
                        }
                    }
                ]
            }
        ],
        "generationConfig": {
            "temperature": 0.2
        }
    };

    const controller = new AbortController();
    const timeoutId = setTimeout(() => controller.abort(), 15000);

    try {
        if (GEMINI_API_KEY === "YOUR_GEMINI_API_KEY_HERE") {
            throw new Error("Missing API Key");
        }

        const response = await fetch(`https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=${GEMINI_API_KEY}`, {
            method: 'POST',
            signal: controller.signal,
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify(payload)
        });
        clearTimeout(timeoutId);

        const raw = await response.json();

        let resultJson;
        if (raw.error) {
            throw new Error(raw.error.message);
        } else {
            let contentStr = raw.candidates[0].content.parts[0].text.trim();
            if (contentStr.startsWith('```json')) contentStr = contentStr.substring(7, contentStr.length - 3);
            if (contentStr.startsWith('```')) contentStr = contentStr.substring(3, contentStr.length - 3);
            resultJson = JSON.parse(contentStr);
        }

        populateReport(resultJson);

        // Save to faux history
        history.push({
            img: currentFileBase64,
            data: resultJson
        });

        showView('report-view');

    } catch (e) {
        clearTimeout(timeoutId);
        console.warn("Gemini Error / Missing Key:", e);
        const fallbackJson = {
            smart_name: "Web_Test_Missing_Key.jpg",
            description: "The API failed. Did you replace YOUR_GEMINI_API_KEY_HERE in app.js with your real Gemini API key? Or a network error occurred.",
            tags: ["Error", "Invalid Key", "Offline"],
            lighting_quality: "0/10",
            sharpness: "0/10"
        };
        populateReport(fallbackJson);
        history.push({
            img: currentFileBase64,
            data: fallbackJson
        });
        showView('report-view');
    }
}

function populateReport(data) {
    document.getElementById('report-img').src = currentFileBase64;
    document.getElementById('report-title').innerText = data.smart_name.replace(/_/g, ' ');
    document.getElementById('report-desc').innerText = data.description;

    const tagsDiv = document.getElementById('report-tags');
    tagsDiv.innerHTML = '';
    data.tags.forEach(tag => {
        const span = document.createElement('span');
        span.className = 'tag';
        span.innerText = `#${tag}`;
        tagsDiv.appendChild(span);
    });

    document.getElementById('metric-light').innerText = data.lighting_quality;
    document.getElementById('metric-sharp').innerText = data.sharpness;

    document.getElementById('meta-res').innerText = currentFileRes;
    document.getElementById('meta-size').innerText = `${currentFileSizeMb} MB`;

    // Reset file input
    fileInput.value = '';
}

function renderHistory() {
    if (history.length === 0) return;

    historyGrid.innerHTML = '';
    [...history].reverse().forEach(item => {
        const div = document.createElement('div');
        div.className = 'history-card';
        div.innerHTML = `
            <img src="${item.img}" alt="thumb">
            <div>
                <strong style="display:block; margin-bottom: 5px;">${item.data.smart_name.replace(/_/g, ' ')}</strong>
                <span class="tag" style="font-size: 0.7rem; padding: 4px 8px;">#${item.data.tags[0] || 'Scanned'}</span>
            </div>
        `;
        div.onclick = () => {
            currentFileBase64 = item.img;
            currentFileRes = "Saved";
            currentFileSizeMb = "?";
            populateReport(item.data);
            showView('report-view');
        };
        historyGrid.appendChild(div);
    });
}
