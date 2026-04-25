// State
let history = [];
let currentFileBase64 = null;
let currentFileSizeMb = 0;
let currentFileRes = "Unknown";

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

    // Use test API key to hit groq directly
    const apiKey = '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';
    const model = 'llama-3.2-11b-vision-preview'; // Testing standard 11b or generic vision
    
    // Wait, you mentioned Groq decommissioned their vision model!
    // Since we are mocking the web test for the user, let's use a free text fallback OR ask the API.
    // If the API fails with "model_decommissioned", we will simulate the AI success locally for the web test demo
    // just so they can feel the UI flow on their phone!

    const payload = {
        model: model,
        messages: [
            {
                role: "user",
                content: [
                    { type: "text", text: "Analyze the attached image. Respond ONLY in valid JSON format using the following structure: {'smart_name': '...', 'description': '...', 'tags': ['...', '...'], 'lighting_quality': '8/10', 'sharpness': '9/10'}. Do NOT include any markdown formatting like ```json, just the raw JSON object." },
                    { type: "image_url", image_url: { url: currentFileBase64 } }
                ]
            }
        ],
        temperature: 0.1
    };

    try {
        const response = await fetch('https://api.groq.com/openai/v1/chat/completions', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${apiKey}`
            },
            body: JSON.stringify(payload)
        });

        const raw = await response.json();
        
        // Handle Groq Error naturally for test mode
        let resultJson;
        if (raw.error) {
            console.warn("Groq API errored (likely vision disabled). Using Fallback MOCK for UI Test.");
            resultJson = {
                smart_name: "Test_Image_MOCK.jpg",
                description: "Groq returned an error: " + raw.error.message + ". This is a MOCK response to let you test the UI on your phone.",
                tags: ["Mock", "Test", "Fallback"],
                lighting_quality: "9/10",
                sharpness: "7/10"
            };
        } else {
            let contentStr = raw.choices[0].message.content.trim();
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
        alert("Network Error: " + e.message);
        showView('library-view');
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
