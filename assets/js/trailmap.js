const trailStops = [
  { id: 1, title: "Start", description: "Begin your journey" },
  { id: 2, title: "Basics", description: "Learn the fundamentals" },
  { id: 3, title: "Practice", description: "Try it yourself" },
  { id: 4, title: "Advanced", description: "Deep dive into complexity" },
  { id: 5, title: "Project", description: "Build something real" },
  { id: 6, title: "Master", description: "Achieve mastery" },
];

const svg = document.getElementById("trailMap");
const width = 600;
const height = 800;
const leftX = 150;
const rightX = 450;
const startY = 80;
const stepY = 140;

if (!svg) {
  return;
}

// Function to create hand-drawn style path with variations
function createHandDrawnPath(x1, y1, x2, y2, variation = 0) {
  const midY = (y1 + y2) / 2;
  const controlOffset = (x2 - x1) / 2;

  // Add randomness for hand-drawn effect - more variation for second line
  const wobbleAmount = 12 + variation * 5;
  const wobble1 = (Math.random() - 0.5) * wobbleAmount;
  const wobble2 = (Math.random() - 0.5) * wobbleAmount;
  const wobble3 = (Math.random() - 0.5) * wobbleAmount;
  const wobble4 = (Math.random() - 0.5) * wobbleAmount;

  // Slightly offset start and end points for variation
  const startOffsetX = (Math.random() - 0.5) * variation * 3;
  const startOffsetY = (Math.random() - 0.5) * variation * 3;
  const endOffsetX = (Math.random() - 0.5) * variation * 3;
  const endOffsetY = (Math.random() - 0.5) * variation * 3;

  const cp1x = x1 + controlOffset + wobble1;
  const cp1y = y1 + (midY - y1) * 0.3 + wobble2;
  const cp2x = x2 - controlOffset + wobble3;
  const cp2y = y2 - (y2 - midY) * 0.3 + wobble4;

  return `M ${x1 + startOffsetX} ${y1 + startOffsetY} C ${cp1x} ${cp1y}, ${cp2x} ${cp2y}, ${x2 + endOffsetX} ${y2 + endOffsetY}`;
}

// Create double paths between points for hand-drawn effect
for (let i = 0; i < trailStops.length - 1; i++) {
  const isLeft = i % 2 === 0;
  const x1 = isLeft ? leftX : rightX;
  const y1 = startY + i * stepY;
  const x2 = isLeft ? rightX : leftX;
  const y2 = startY + (i + 1) * stepY;

  // Create two slightly different paths for hand-drawn effect
  for (let j = 0; j < 2; j++) {
    const path = document.createElementNS("http://www.w3.org/2000/svg", "path");
    path.setAttribute("class", "trail-path");
    path.setAttribute("d", createHandDrawnPath(x1, y1, x2, y2, j));

    // Second line slightly more transparent
    if (j === 1) {
      path.style.opacity = "0.5";
      path.style.strokeWidth = "2.5";
    }

    // Animate path drawing
    const length = path.getTotalLength();
    path.style.strokeDasharray = length;
    path.style.strokeDashoffset = length;
    path.style.animation = `drawPath 1s ease-in-out ${i * 0.3 + j * 0.05}s forwards`;

    svg.appendChild(path);
  }
}

// Add CSS animation
const style = document.createElement("style");
style.textContent = `
    @keyframes drawPath {
        to { stroke-dashoffset: 0; }
    }
    @keyframes fadeIn {
        from { opacity: 0; transform: scale(0.5); }
        to { opacity: 1; transform: scale(1); }
    }
`;
document.head.appendChild(style);

// Create points
trailStops.forEach((stop, i) => {
  const isLeft = i % 2 === 0;
  const x = isLeft ? leftX : rightX;
  const y = startY + i * stepY;

  const group = document.createElementNS("http://www.w3.org/2000/svg", "g");
  group.setAttribute("class", "trail-point");
  group.style.animation = `fadeIn 0.5s ease-out ${i * 0.3 + 0.5}s backwards`;

  // Circle
  const circle = document.createElementNS(
    "http://www.w3.org/2000/svg",
    "circle",
  );
  circle.setAttribute("cx", x);
  circle.setAttribute("cy", y);
  circle.setAttribute("r", 15);
  circle.setAttribute("fill", "#4a90e2");
  circle.setAttribute("stroke", "white");
  circle.setAttribute("stroke-width", 3);

  // Number
  const number = document.createElementNS("http://www.w3.org/2000/svg", "text");
  number.setAttribute("x", x);
  number.setAttribute("y", y + 5);
  number.setAttribute("text-anchor", "middle");
  number.setAttribute("fill", "white");
  number.setAttribute("font-size", "16");
  number.setAttribute("font-weight", "bold");
  number.textContent = stop.id;

  // Title
  const title = document.createElementNS("http://www.w3.org/2000/svg", "text");
  title.setAttribute("x", isLeft ? x - 30 : x + 30);
  title.setAttribute("y", y + 5);
  title.setAttribute("text-anchor", isLeft ? "end" : "start");
  title.setAttribute("fill", "#333");
  title.setAttribute("font-size", "18");
  title.setAttribute("font-weight", "600");
  title.textContent = stop.title;

  // Description
  const desc = document.createElementNS("http://www.w3.org/2000/svg", "text");
  desc.setAttribute("x", isLeft ? x - 30 : x + 30);
  desc.setAttribute("y", y + 22);
  desc.setAttribute("text-anchor", isLeft ? "end" : "start");
  desc.setAttribute("fill", "#666");
  desc.setAttribute("font-size", "12");
  desc.textContent = stop.description;

  group.appendChild(circle);
  group.appendChild(number);
  group.appendChild(title);
  group.appendChild(desc);

  // Click handler
  group.addEventListener("click", () => {
    alert(`${stop.title}: ${stop.description}`);
  });

  svg.appendChild(group);
});
