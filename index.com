<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Trò Chơi Hái Hoa Dân Chủ 20/10 - Lớp 11A3</title>
    <!-- Tailwind CSS -->
    <script src="https://cdn.tailwindcss.com"></script>
    <!-- Google Fonts -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Comfortaa:wght@600;700&family=Nunito:wght@400;600;700;800;900&display=swap" rel="stylesheet">
    <!-- FontAwesome Icons -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <!-- Canvas Confetti -->
    <script src="https://cdn.jsdelivr.net/npm/canvas-confetti@1.6.0/dist/confetti.browser.min.js"></script>

    <script>
        tailwind.config = {
            theme: {
                extend: {
                    colors: {
                        brand: {
                            pink: '#ff4b82',
                            rose: '#ff2a6d',
                            light: '#fff0f5',
                            gold: '#ffb703',
                            green: '#2a9d8f'
                        }
                    },
                    fontFamily: {
                        sans: ['Nunito', 'sans-serif'],
                        title: ['Comfortaa', 'cursive'],
                    }
                }
            }
        }
    </script>

    <style>
        body {
            background: radial-gradient(circle at center, #fff5f8 0%, #ffd6e0 50%, #d8f3dc 100%);
            min-height: 100vh;
            user-select: none;
            overflow-x: hidden;
        }

        /* Swaying Animation Inside Foliage */
        @keyframes sway-pendant {
            0% { transform: rotate(-7deg); }
            50% { transform: rotate(7deg); }
            100% { transform: rotate(-7deg); }
        }

        @keyframes sway-pendant-alt {
            0% { transform: rotate(6deg); }
            50% { transform: rotate(-6deg); }
            100% { transform: rotate(6deg); }
        }

        .flower-pendant {
            transform-origin: top center;
            animation: sway-pendant 3.5s ease-in-out infinite;
            transition: transform 0.25s ease, filter 0.25s ease;
        }

        .flower-pendant:nth-child(2n) { animation: sway-pendant-alt 4s ease-in-out infinite; }
        .flower-pendant:nth-child(3n) { animation-duration: 3.2s; }
        .flower-pendant:nth-child(4n) { animation-duration: 4.2s; }

        .flower-pendant:hover:not(.picked) {
            animation-play-state: paused;
            transform: scale(1.22) rotate(0deg);
            z-index: 60;
        }

        .flower-pendant:hover:not(.picked) .flower-body {
            filter: drop-shadow(0 0 14px rgba(255, 42, 109, 0.9));
        }

        .flower-pendant.picked {
            filter: grayscale(0.9) opacity(0.45);
            animation: none !important;
            cursor: not-allowed;
        }

        /* Glassmorphism Modal */
        .glass-modal {
            background: rgba(255, 255, 255, 0.97);
            backdrop-filter: blur(16px);
            border: 2px solid rgba(255, 182, 193, 0.8);
        }

        @keyframes timer-warning {
            0%, 100% { color: #ef4444; transform: scale(1); }
            50% { color: #dc2626; transform: scale(1.18); }
        }
        .timer-low {
            animation: timer-warning 0.5s infinite;
        }
    </style>
</head>
<body class="font-sans text-gray-800 flex flex-col min-h-screen relative justify-between">

    <!-- Header Toolbar -->
    <header class="w-full py-3 px-4 text-center z-20">
        <div class="max-w-4xl mx-auto bg-white/90 backdrop-blur-md rounded-3xl p-3 md:p-4 shadow-xl border border-pink-200">
            <div class="inline-block bg-gradient-to-r from-pink-500 via-rose-500 to-purple-500 text-white font-bold px-4 py-1 rounded-full text-xs md:text-sm mb-1 shadow-sm tracking-wide">
                <i class="fa-solid fa-heart mr-1"></i> MỪNG NGÀY PHỤ NỮ VIỆT NAM 20/10 - LỚP 11A3
            </div>
            <h1 class="font-title text-xl md:text-3xl font-black text-transparent bg-clip-text bg-gradient-to-r from-pink-600 via-rose-500 to-purple-600 uppercase tracking-wide">
                Hái Hoa Dân Chủ - Cây Hoa Cổ Thụ
            </h1>
            
            <!-- Controls Toolbar -->
            <div class="mt-2.5 flex flex-wrap items-center justify-between gap-2 pt-2 border-t border-pink-100 text-xs md:text-sm">
                <div class="flex items-center gap-2 bg-pink-100/90 px-3.5 py-1 rounded-2xl border border-pink-200 font-bold">
                    <span class="text-xs text-pink-700 uppercase">Đã hái:</span>
                    <span id="picked-count" class="text-rose-600 text-base font-black">0</span>
                    <span class="text-gray-400">/</span>
                    <span class="text-gray-700">20 Hoa Trên Tán Cây</span>
                </div>

                <div class="flex items-center gap-2">
                    <button id="btn-sound" onclick="toggleSound()" class="px-3 py-1.5 rounded-xl bg-white hover:bg-pink-50 text-pink-600 border border-pink-200 shadow-sm font-bold transition flex items-center gap-1.5">
                        <i class="fa-solid fa-volume-high" id="sound-icon"></i>
                        <span id="sound-text">Âm Thanh</span>
                    </button>

                    <button onclick="openQuestionList()" class="px-3 py-1.5 rounded-xl bg-purple-600 hover:bg-purple-700 text-white shadow-sm font-bold transition flex items-center gap-1.5">
                        <i class="fa-solid fa-list-check"></i>
                        <span>Bảng MC Tra Cứu</span>
                    </button>

                    <button onclick="confirmReset()" class="px-3 py-1.5 rounded-xl bg-rose-500 hover:bg-rose-600 text-white shadow-sm font-bold transition flex items-center gap-1.5">
                        <i class="fa-solid fa-rotate-right"></i>
                        <span>Treo Lại Hoa</span>
                    </button>
                </div>
            </div>
        </div>
    </header>

    <!-- Main Section: GIANT TREE WITH FLOWERS strictly WITHIN CANOPY -->
    <main class="flex-grow w-full max-w-6xl mx-auto px-2 relative flex items-center justify-center my-1">
        
        <!-- Big Tree Canvas Container (Relative 800x600 coordinate space) -->
        <div class="relative w-full max-w-[900px] aspect-[4/3] max-h-[72vh] flex items-center justify-center">
            
            <!-- SVG HUGE ANCIENT TREE -->
            <svg class="absolute inset-0 w-full h-full drop-shadow-2xl z-0 pointer-events-none" viewBox="0 0 800 600" preserveAspectRatio="xMidYMid meet">
                <defs>
                    <!-- Trunk Wood Gradient -->
                    <linearGradient id="trunkGrad" x1="0%" y1="0%" x2="100%" y2="0%">
                        <stop offset="0%" stop-color="#211007"/>
                        <stop offset="35%" stop-color="#4a2813"/>
                        <stop offset="70%" stop-color="#6b3a1a"/>
                        <stop offset="100%" stop-color="#190b04"/>
                    </linearGradient>

                    <!-- Dense Lush Green Foliage Radial Gradients -->
                    <radialGradient id="canopyDark" cx="50%" cy="50%" r="50%">
                        <stop offset="0%" stop-color="#40916c"/>
                        <stop offset="65%" stop-color="#1b4332"/>
                        <stop offset="100%" stop-color="#081c15"/>
                    </radialGradient>
                    
                    <radialGradient id="canopyLight" cx="40%" cy="40%" r="60%">
                        <stop offset="0%" stop-color="#95d5b2"/>
                        <stop offset="70%" stop-color="#2d6a4f"/>
                        <stop offset="100%" stop-color="#1b4332"/>
                    </radialGradient>

                    <radialGradient id="canopyHighlight" cx="35%" cy="35%" r="65%">
                        <stop offset="0%" stop-color="#b7e4c7"/>
                        <stop offset="60%" stop-color="#52b788"/>
                        <stop offset="100%" stop-color="#2d6a4f"/>
                    </radialGradient>

                    <!-- Pink Flower Aura Glow -->
                    <radialGradient id="pinkAura" cx="50%" cy="50%" r="50%">
                        <stop offset="0%" stop-color="#ffb7d5" stop-opacity="0.6"/>
                        <stop offset="100%" stop-color="#ff4b82" stop-opacity="0"/>
                    </radialGradient>
                </defs>

                <!-- Hill Base Ground -->
                <ellipse cx="400" cy="580" rx="390" ry="20" fill="#1b4332" opacity="0.95"/>
                <ellipse cx="400" cy="585" rx="320" ry="12" fill="#2d6a4f"/>

                <!-- Massive Canopy Layer 1 (Background Foliage Bulk) -->
                <ellipse cx="400" cy="270" rx="370" ry="230" fill="url(#canopyDark)"/>
                <circle cx="210" cy="250" r="180" fill="url(#canopyDark)"/>
                <circle cx="590" cy="250" r="180" fill="url(#canopyDark)"/>
                <circle cx="400" cy="160" r="170" fill="url(#canopyDark)"/>

                <!-- Massive Canopy Layer 2 (Mid-ground Foliage) -->
                <ellipse cx="400" cy="260" rx="330" ry="200" fill="url(#canopyLight)"/>
                <circle cx="240" cy="220" r="150" fill="url(#canopyLight)"/>
                <circle cx="560" cy="220" r="150" fill="url(#canopyLight)"/>
                <circle cx="400" cy="140" r="140" fill="url(#canopyLight)"/>
                <circle cx="160" cy="300" r="120" fill="url(#canopyLight)"/>
                <circle cx="640" cy="300" r="120" fill="url(#canopyLight)"/>

                <!-- Giant Trunk & Roots -->
                <path d="M 330 580 Q 370 500 370 410 L 430 410 Q 430 500 470 580 Z" fill="url(#trunkGrad)"/>
                <path d="M 370 420 Q 360 330 380 260 L 420 260 Q 440 330 430 420 Z" fill="url(#trunkGrad)"/>

                <!-- Strong Main Internal Branches (Under Foliage) -->
                <path d="M 380 320 Q 250 290 140 330 Q 240 310 380 340 Z" fill="url(#trunkGrad)"/>
                <path d="M 420 320 Q 550 290 660 330 Q 560 310 420 340 Z" fill="url(#trunkGrad)"/>
                <path d="M 385 280 Q 300 200 220 180 Q 300 230 385 300 Z" fill="url(#trunkGrad)"/>
                <path d="M 415 280 Q 500 200 580 180 Q 500 230 415 300 Z" fill="url(#trunkGrad)"/>
                <path d="M 395 260 Q 360 150 370 90 Q 385 150 400 250 Z" fill="url(#trunkGrad)"/>

                <!-- Massive Canopy Layer 3 (Foreground Bright Foliage Highlights) -->
                <circle cx="300" cy="290" r="110" fill="url(#canopyHighlight)" opacity="0.95"/>
                <circle cx="500" cy="290" r="110" fill="url(#canopyHighlight)" opacity="0.95"/>
                <circle cx="400" cy="200" r="130" fill="url(#canopyHighlight)" opacity="0.95"/>
                <circle cx="210" cy="210" r="100" fill="url(#canopyHighlight)" opacity="0.9"/>
                <circle cx="590" cy="210" r="100" fill="url(#canopyHighlight)" opacity="0.9"/>

                <!-- Pink Blossom Aura Clusters within Canopy -->
                <circle cx="320" cy="180" r="100" fill="url(#pinkAura)"/>
                <circle cx="480" cy="180" r="100" fill="url(#pinkAura)"/>
                <circle cx="220" cy="270" r="90" fill="url(#pinkAura)"/>
                <circle cx="580" cy="270" r="90" fill="url(#pinkAura)"/>
            </svg>

            <!-- 20 FLOWERS CONTAINER - ALL POSITIONS CALIBRATED INSIDE CANOPY AREA (X: 16%..84%, Y: 12%..65%) -->
            <div id="tree-flowers-container" class="absolute inset-0 w-full h-full z-10 pointer-events-none">
                <!-- 20 Hanging flowers rendered via JS -->
            </div>
        </div>

    </main>

    <!-- Footer -->
    <footer class="py-2 text-center text-xs font-semibold text-rose-800/90 z-20">
        ✨ Chúc các Cô, các Mẹ và các Bạn Nữ 11A3 Vui Vẻ - Hạnh Phúc - Luôn Tươi Thắm Như Những Bông Hoa! ✨
    </footer>

    <!-- QUESTION POPUP MODAL -->
    <div id="question-modal" class="fixed inset-0 bg-black/60 backdrop-blur-sm z-50 flex items-center justify-center p-4 hidden">
        <div class="glass-modal max-w-2xl w-full rounded-3xl shadow-2xl p-6 md:p-8 relative transform transition-all duration-300 scale-95 opacity-0" id="modal-content">
            
            <!-- Close Button -->
            <button onclick="closeModal()" class="absolute top-4 right-4 w-10 h-10 bg-gray-100 hover:bg-pink-100 text-gray-500 hover:text-pink-600 rounded-full flex items-center justify-center transition shadow-inner">
                <i class="fa-solid fa-xmark text-xl"></i>
            </button>

            <!-- Question Header & Timer -->
            <div class="flex items-center justify-between border-b border-pink-100 pb-4 mb-4">
                <div class="flex items-center gap-3">
                    <div id="modal-flower-badge" class="w-12 h-12 rounded-2xl bg-gradient-to-tr from-pink-500 to-rose-500 text-white font-black text-2xl flex items-center justify-center shadow-md">
                        1
                    </div>
                    <div>
                        <h3 class="text-xs font-black tracking-wider text-pink-500 uppercase">Bông Hoa Dân Chủ</h3>
                        <h2 id="modal-question-title" class="font-title text-xl font-bold text-gray-800">Câu hỏi số 01</h2>
                    </div>
                </div>

                <!-- Timer Counter -->
                <div class="flex items-center gap-2 bg-rose-50 border border-rose-200 px-4 py-2 rounded-2xl shadow-inner">
                    <i class="fa-solid fa-stopwatch text-rose-500 text-lg"></i>
                    <span id="timer-display" class="font-black text-2xl text-rose-600 w-8 text-center">15</span>
                    <span class="text-xs font-bold text-rose-400">giây</span>
                </div>
            </div>

            <!-- Question Text Box -->
            <div class="bg-gradient-to-br from-pink-50/90 to-rose-50/50 p-6 rounded-2xl border border-pink-100 my-4 shadow-inner min-h-[120px] flex items-center justify-center">
                <p id="modal-question-text" class="text-lg md:text-xl font-bold text-gray-800 text-center leading-relaxed">
                    Nội dung câu hỏi...
                </p>
            </div>

            <!-- Answer Box (Hidden by default) -->
            <div id="answer-box" class="hidden bg-gradient-to-r from-emerald-50 to-teal-50 p-5 rounded-2xl border border-emerald-200 my-4 text-center transform transition-all">
                <div class="inline-block bg-emerald-500 text-white text-xs font-black px-3 py-1 rounded-full uppercase mb-2 shadow-sm">
                    <i class="fa-solid fa-lightbulb mr-1"></i> Đáp Án Chính Xác
                </div>
                <p id="modal-answer-text" class="text-lg md:text-xl font-black text-emerald-800">
                    Nội dung đáp án...
                </p>
            </div>

            <!-- Action Buttons -->
            <div class="flex flex-col sm:flex-row items-center justify-end gap-3 mt-6 pt-4 border-t border-gray-100">
                <button id="btn-reveal-answer" onclick="revealAnswer()" class="w-full sm:w-auto px-6 py-3 bg-gradient-to-r from-amber-400 to-yellow-500 hover:from-amber-500 hover:to-yellow-600 text-slate-900 font-extrabold rounded-xl shadow-md hover:shadow-lg transition flex items-center justify-center gap-2">
                    <i class="fa-solid fa-key"></i>
                    <span>Xem Đáp Án</span>
                </button>
                <button onclick="closeModal()" class="w-full sm:w-auto px-6 py-3 bg-pink-600 hover:bg-pink-700 text-white font-extrabold rounded-xl shadow-md transition flex items-center justify-center gap-2">
                    <i class="fa-solid fa-check"></i>
                    <span>Hoàn Thành / Đóng</span>
                </button>
            </div>
        </div>
    </div>

    <!-- LIST OF QUESTIONS MODAL (FOR MC / TEACHER) -->
    <div id="list-modal" class="fixed inset-0 bg-black/60 backdrop-blur-sm z-50 flex items-center justify-center p-4 hidden">
        <div class="bg-white max-w-3xl w-full h-[85vh] rounded-3xl shadow-2xl p-6 flex flex-col relative">
            <div class="flex items-center justify-between pb-4 border-b border-gray-200">
                <div class="flex items-center gap-2 text-purple-600">
                    <i class="fa-solid fa-list-check text-2xl"></i>
                    <h2 class="font-title text-xl font-bold">Danh Sách 20 Câu Hỏi & Đáp Án 11A3</h2>
                </div>
                <button onclick="closeQuestionList()" class="w-8 h-8 bg-gray-100 hover:bg-gray-200 text-gray-600 rounded-full flex items-center justify-center transition">
                    <i class="fa-solid fa-xmark"></i>
                </button>
            </div>

            <div id="all-questions-container" class="flex-grow overflow-y-auto py-4 space-y-3 pr-2">
                <!-- List items loaded via JS -->
            </div>

            <div class="pt-3 border-t border-gray-100 flex justify-end">
                <button onclick="closeQuestionList()" class="px-5 py-2.5 bg-gray-600 text-white font-bold rounded-xl hover:bg-gray-700">
                    Đóng
                </button>
            </div>
        </div>
    </div>

    <!-- JAVASCRIPT GAME LOGIC -->
    <script>
        // Exact 20 Questions Dataset
        const quizData = [
            { id: 1, q: "Ngày Phụ nữ Việt Nam 20/10 chính thức được thành lập vào năm nào?", a: "Năm 1930." },
            { id: 2, q: "Tám chữ vàng Bác Hồ khen tặng phụ nữ Việt Nam trong thời kỳ kháng chiến là gì?", a: "Anh hùng – Bất khuất – Trung hậu – Đảm đang." },
            { id: 3, q: "Cái gì con gái càng xài thì càng ngắn, nhưng hễ hết là phải đi mua cây mới ngay?", a: "Cây son môi." },
            { id: 4, q: "Một người đi dưới trời mưa lớn không mang ô, không đội mũ, người ướt sũng nhưng không sợi tóc nào bị ướt. Vì sao?", a: "Vì người đó bị hói / không có tóc." },
            { id: 5, q: "Cái gì bạn chỉ có thể cầm bằng tay trái mà không bao giờ cầm được bằng tay phải?", a: "Cổ tay phải (hoặc khuỷu tay phải)." },
            { id: 6, q: "Vật gì có mặt nhưng không có mắt, có kim nhưng không biết may, chạy suốt ngày đêm mà chẳng đi đến đâu?", a: "Chiếc đồng hồ." },
            { id: 7, q: "Nữ anh hùng trẻ tuổi miền đất đỏ hiên ngang trước quân thù là ai?", a: "Chị Võ Thị Sáu." },
            { id: 8, q: "Bỏ ngoài nướng trong, ăn ngoài bỏ trong là ăn món gì?", a: "Bắp ngô nướng." },
            { id: 9, q: "Cái gì mua màu đen, dùng biến thành màu đỏ, lúc vứt đi lại có màu xám trắng?", a: "Hòn than tổ ong / than củi." },
            { id: 10, q: "Bệnh gì bác sĩ tài giỏi đến mấy cũng bó tay, nhưng chỉ cần nghe tiếng \"ting ting\" ngân hàng là tự khỏi?", a: "Bệnh \"viêm màng túi\" (hết tiền)." },
            { id: 11, q: "Người phụ nữ duy nhất xuất hiện trên các tờ tiền polymer đang lưu hành tại Việt Nam là ai?", a: "Không có ai (chỉ có hình ảnh Bác Hồ, di tích và danh lam cảnh đẹp)." },
            { id: 12, q: "Vật gì càng rửa thì lại càng bẩn?", a: "Nước." },
            { id: 13, q: "Nữ thi sĩ nào là tác giả của bài thơ \"Sóng\" quen thuộc trong chương trình Ngữ văn?", a: "Nhà thơ Xuân Quỳnh." },
            { id: 14, q: "Từ nào trong từ điển tiếng Việt mà tất cả mọi người đều phát âm là \"sai\"?", a: "Từ \"Sai\"." },
            { id: 15, q: "Một bạn nam lớp mình rơi xuống hồ sâu 3 mét, không biết bơi nhưng người không hề bị ướt. Tại sao?", a: "Vì hồ nước đã cạn khô." },
            { id: 16, q: "Cái gì thuộc về bạn, do bạn sở hữu nhưng mọi người xung quanh lại dùng nhiều hơn bạn?", a: "Tên của bạn." },
            { id: 17, q: "Nếu bạn nữ nói: \"Hôm nay em ăn gì cũng được\", xác suất bạn nam chọn trúng món bạn ấy ưng ý là bao nhiêu %?", a: "0% (vì món nào đề xuất ra cũng sẽ bị từ chối)." },
            { id: 18, q: "Hai người cùng nhìn lên bầu trời đêm, một người thấy trăng sao, người kia chỉ thấy một màn đêm đen kịt. Vì sao?", a: "Vì người thứ hai đang nhắm mắt." },
            { id: 19, q: "Thử thách phản xạ: Kể tên thật nhanh 3 bạn nữ có mái tóc dài nhất lớp 11A3 trong vòng 5 giây!", a: "Nêu đúng 3 bạn nữ trong lớp." },
            { id: 20, q: "Ai là người luôn nhắc cả lớp giữ trật tự, nhưng lớp vừa im lặng thì lại là người nói nhiều nhất suốt 45 phút?", a: "Thầy/Cô giáo đứng trên bục giảng." }
        ];

        // STRICTLY CALIBRATED POSITIONS INSIDE CANOPY AREA (Percentages relative to Tree Container)
        // All positions ensure the string and flower body remain completely inside foliage bounds.
        const canopyFlowerPositions = [
            { x: 42, y: 12 }, { x: 30, y: 16 }, { x: 56, y: 16 }, { x: 22, y: 22 },
            { x: 68, y: 22 }, { x: 36, y: 24 }, { x: 48, y: 24 }, { x: 17, y: 32 },
            { x: 74, y: 32 }, { x: 28, y: 34 }, { x: 62, y: 34 }, { x: 44, y: 36 },
            { x: 21, y: 44 }, { x: 70, y: 44 }, { x: 32, y: 46 }, { x: 58, y: 46 },
            { x: 43, y: 48 }, { x: 26, y: 55 }, { x: 64, y: 55 }, { x: 47, y: 58 }
        ];

        // Vibrant Flower SVGs
        const flowerIcons = [
            // Pink Rose Pendant
            `<svg class="w-10 h-10 md:w-12 md:h-12 flower-body drop-shadow-md" viewBox="0 0 100 100">
                <circle cx="50" cy="50" r="32" fill="#ff4b82"/>
                <circle cx="36" cy="42" r="20" fill="#ff70a6"/>
                <circle cx="64" cy="42" r="20" fill="#ff70a6"/>
                <circle cx="50" cy="32" r="20" fill="#ff85b3"/>
                <circle cx="50" cy="50" r="14" fill="#ffb703"/>
            </svg>`,
            // Magenta Blossom
            `<svg class="w-10 h-10 md:w-12 md:h-12 flower-body drop-shadow-md" viewBox="0 0 100 100">
                <g fill="#f72585">
                    <circle cx="50" cy="22" r="12"/>
                    <circle cx="50" cy="78" r="12"/>
                    <circle cx="22" cy="50" r="12"/>
                    <circle cx="78" cy="50" r="12"/>
                    <circle cx="30" cy="30" r="12"/>
                    <circle cx="70" cy="30" r="12"/>
                    <circle cx="30" cy="70" r="12"/>
                    <circle cx="70" cy="70" r="12"/>
                </g>
                <circle cx="50" cy="50" r="18" fill="#ffb703"/>
            </svg>`,
            // Purple Blossom
            `<svg class="w-10 h-10 md:w-12 md:h-12 flower-body drop-shadow-md" viewBox="0 0 100 100">
                <g fill="#7209b7">
                    <circle cx="50" cy="24" r="15"/>
                    <circle cx="28" cy="46" r="15"/>
                    <circle cx="72" cy="46" r="15"/>
                    <circle cx="36" cy="68" r="15"/>
                    <circle cx="64" cy="68" r="15"/>
                </g>
                <circle cx="50" cy="50" r="15" fill="#4cc9f0"/>
            </svg>`,
            // Golden Blossom
            `<svg class="w-10 h-10 md:w-12 md:h-12 flower-body drop-shadow-md" viewBox="0 0 100 100">
                <g fill="#ffb703">
                    <circle cx="50" cy="24" r="14"/>
                    <circle cx="26" cy="50" r="14"/>
                    <circle cx="74" cy="50" r="14"/>
                    <circle cx="33" cy="70" r="14"/>
                    <circle cx="67" cy="70" r="14"/>
                </g>
                <circle cx="50" cy="50" r="16" fill="#ff2a6d"/>
            </svg>`
        ];

        // State Variables
        let pickedFlowers = JSON.parse(localStorage.getItem('pickedFlowers_2010_11A3')) || [];
        let currentActiveQuestion = null;
        let isSoundEnabled = true;
        let audioCtx = null;
        let timerInterval = null;
        let timeLeft = 15;

        // Sound Initializer
        function initAudio() {
            if (!audioCtx) {
                audioCtx = new (window.AudioContext || window.webkitAudioContext)();
            }
        }

        function toggleSound() {
            initAudio();
            isSoundEnabled = !isSoundEnabled;
            const btnIcon = document.getElementById('sound-icon');
            
            if (isSoundEnabled) {
                btnIcon.className = "fa-solid fa-volume-high";
                playPickSound();
            } else {
                btnIcon.className = "fa-solid fa-volume-xmark text-gray-400";
            }
        }

        // Web Audio Synthesizer Effects
        function playPickSound() {
            if (!isSoundEnabled) return;
            initAudio();
            try {
                const osc = audioCtx.createOscillator();
                const gain = audioCtx.createGain();
                osc.type = 'sine';
                osc.frequency.setValueAtTime(520, audioCtx.currentTime);
                osc.frequency.exponentialRampToValueAtTime(1040, audioCtx.currentTime + 0.18);
                gain.gain.setValueAtTime(0.25, audioCtx.currentTime);
                gain.gain.exponentialRampToValueAtTime(0.01, audioCtx.currentTime + 0.18);
                osc.connect(gain);
                gain.connect(audioCtx.destination);
                osc.start();
                osc.stop(audioCtx.currentTime + 0.18);
            } catch(e){}
        }

        function playTickSound() {
            if (!isSoundEnabled) return;
            initAudio();
            try {
                const osc = audioCtx.createOscillator();
                const gain = audioCtx.createGain();
                osc.type = 'triangle';
                osc.frequency.setValueAtTime(800, audioCtx.currentTime);
                gain.gain.setValueAtTime(0.06, audioCtx.currentTime);
                gain.gain.exponentialRampToValueAtTime(0.001, audioCtx.currentTime + 0.04);
                osc.connect(gain);
                gain.connect(audioCtx.destination);
                osc.start();
                osc.stop(audioCtx.currentTime + 0.04);
            } catch(e){}
        }

        function playFanfareSound() {
            if (!isSoundEnabled) return;
            initAudio();
            try {
                const notes = [523.25, 659.25, 783.99, 1046.50];
                notes.forEach((freq, idx) => {
                    const osc = audioCtx.createOscillator();
                    const gain = audioCtx.createGain();
                    osc.type = 'sine';
                    osc.frequency.setValueAtTime(freq, audioCtx.currentTime + idx * 0.08);
                    gain.gain.setValueAtTime(0.2, audioCtx.currentTime + idx * 0.08);
                    gain.gain.exponentialRampToValueAtTime(0.001, audioCtx.currentTime + idx * 0.08 + 0.3);
                    osc.connect(gain);
                    gain.connect(audioCtx.destination);
                    osc.start(audioCtx.currentTime + idx * 0.08);
                    osc.stop(audioCtx.currentTime + idx * 0.08 + 0.3);
                });
            } catch(e){}
        }

        // Render Flowers inside Canopy Container
        function renderTreeFlowers() {
            const container = document.getElementById('tree-flowers-container');
            container.innerHTML = '';

            quizData.forEach((item, index) => {
                const isPicked = pickedFlowers.includes(item.id);
                const pos = canopyFlowerPositions[index];
                const flowerIcon = flowerIcons[index % flowerIcons.length];

                // Pendant Container
                const pendantEl = document.createElement('div');
                pendantEl.className = `flower-pendant pointer-events-auto absolute flex flex-col items-center cursor-pointer ${
                    isPicked ? 'picked' : ''
                }`;
                
                pendantEl.style.left = `${pos.x}%`;
                pendantEl.style.top = `${pos.y}%`;

                pendantEl.onclick = () => selectFlower(item.id);

                // Hanging Line SVG + Flower Body
                pendantEl.innerHTML = `
                    <!-- Short Vine Line within Foliage -->
                    <svg class="w-1.5 h-7 md:h-8 overflow-visible" viewBox="0 0 6 35">
                        <line x1="3" y1="0" x2="3" y2="35" stroke="#1b4332" stroke-width="2.5" stroke-dasharray="2,2"/>
                        <circle cx="3" cy="2" r="2.5" fill="#52b788"/>
                    </svg>

                    <!-- Flower Body & Number Tag -->
                    <div class="relative flex flex-col items-center mt-[-3px]">
                        ${isPicked ? `
                            <div class="w-9 h-9 md:w-11 md:h-11 bg-gray-200/90 rounded-full border-2 border-dashed border-gray-400 flex items-center justify-center text-gray-500 shadow-inner">
                                <i class="fa-solid fa-check text-base text-emerald-600 font-bold"></i>
                            </div>
                        ` : flowerIcon}

                        <span class="mt-[-6px] px-1.5 py-0.2 ${
                            isPicked ? 'bg-gray-500' : 'bg-gradient-to-r from-pink-600 to-rose-600'
                        } text-white font-black text-[9px] md:text-[11px] rounded-full shadow-md border border-white">
                            ${item.id}
                        </span>
                    </div>
                `;

                container.appendChild(pendantEl);
            });

            document.getElementById('picked-count').textContent = pickedFlowers.length;
        }

        // Picking Flower Interaction
        function selectFlower(id) {
            initAudio();
            currentActiveQuestion = quizData.find(q => q.id === id);
            if (!currentActiveQuestion) return;

            playPickSound();

            // Populate Modal Data
            document.getElementById('modal-flower-badge').textContent = id;
            document.getElementById('modal-question-title').textContent = `Câu hỏi số ${id < 10 ? '0' + id : id}`;
            document.getElementById('modal-question-text').textContent = currentActiveQuestion.q;
            document.getElementById('modal-answer-text').textContent = currentActiveQuestion.a;

            // Reset States
            document.getElementById('answer-box').classList.add('hidden');
            document.getElementById('btn-reveal-answer').classList.remove('hidden');

            // Show Popup
            const modal = document.getElementById('question-modal');
            const modalContent = document.getElementById('modal-content');
            modal.classList.remove('hidden');
            
            setTimeout(() => {
                modalContent.classList.remove('scale-95', 'opacity-0');
                modalContent.classList.add('scale-100', 'opacity-100');
            }, 10);

            startTimer();
        }

        // Countdown Timer
        function startTimer() {
            clearInterval(timerInterval);
            timeLeft = 15;
            const timerDisplay = document.getElementById('timer-display');
            timerDisplay.textContent = timeLeft;
            timerDisplay.classList.remove('timer-low');

            timerInterval = setInterval(() => {
                timeLeft--;
                timerDisplay.textContent = timeLeft;
                playTickSound();

                if (timeLeft <= 5) {
                    timerDisplay.classList.add('timer-low');
                }

                if (timeLeft <= 0) {
                    clearInterval(timerInterval);
                }
            }, 1000);
        }

        // Reveal Answer & Fireworks
        function revealAnswer() {
            clearInterval(timerInterval);
            const answerBox = document.getElementById('answer-box');
            const btnReveal = document.getElementById('btn-reveal-answer');

            answerBox.classList.remove('hidden');
            btnReveal.classList.add('hidden');

            playFanfareSound();

            confetti({
                particleCount: 120,
                spread: 90,
                origin: { y: 0.6 }
            });
        }

        // Close Modal & Mark Picked State
        function closeModal() {
            clearInterval(timerInterval);
            if (currentActiveQuestion && !pickedFlowers.includes(currentActiveQuestion.id)) {
                pickedFlowers.push(currentActiveQuestion.id);
                localStorage.setItem('pickedFlowers_2010_11A3', JSON.stringify(pickedFlowers));
                renderTreeFlowers();
            }

            const modal = document.getElementById('question-modal');
            const modalContent = document.getElementById('modal-content');

            modalContent.classList.remove('scale-100', 'opacity-100');
            modalContent.classList.add('scale-95', 'opacity-0');

            setTimeout(() => {
                modal.classList.add('hidden');
            }, 200);
        }

        // Reset Game Progress
        function confirmReset() {
            if (confirm("Bạn muốn treo lại toàn bộ 20 bông hoa lên tán cây để chơi lại?")) {
                pickedFlowers = [];
                localStorage.removeItem('pickedFlowers_2010_11A3');
                renderTreeFlowers();
                playPickSound();
            }
        }

        // Open Question List Modal for MC
        function openQuestionList() {
            const container = document.getElementById('all-questions-container');
            container.innerHTML = '';

            quizData.forEach((q) => {
                const isPicked = pickedFlowers.includes(q.id);
                const item = document.createElement('div');
                item.className = `p-4 rounded-2xl border ${isPicked ? 'bg-emerald-50/70 border-emerald-200' : 'bg-gray-50 border-gray-200'} transition`;

                item.innerHTML = `
                    <div class="flex items-start gap-3">
                        <span class="px-2.5 py-1 ${isPicked ? 'bg-emerald-500' : 'bg-pink-500'} text-white font-black text-xs rounded-lg whitespace-nowrap">
                            Câu ${q.id}
                        </span>
                        <div class="flex-grow">
                            <p class="font-bold text-gray-800 text-sm md:text-base">${q.q}</p>
                            <p class="text-sm font-bold text-emerald-700 mt-1">👉 ${q.a}</p>
                        </div>
                    </div>
                `;

                container.appendChild(item);
            });

            document.getElementById('list-modal').classList.remove('hidden');
        }

        function closeQuestionList() {
            document.getElementById('list-modal').classList.add('hidden');
        }

        // Initialize on load
        window.onload = function() {
            renderTreeFlowers();
        };
    </script>
</body>
</html>
