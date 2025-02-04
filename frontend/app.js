const apiUrl = process.env.API_URL || "https://default-api-url.com/staging/tasks"; // Fallback URL


// Add task
document.getElementById("task-form").addEventListener("submit", async (e) => {
    e.preventDefault();
    const taskName = document.getElementById("task-name").value;

    const response = await fetch(apiUrl, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ name: taskName }),
    });

    if (response.ok) {
        alert("Task added!");
        document.getElementById("task-name").value = "";
        loadTasks();
    } else {
        alert("Failed to add task.");
    }
});

// Load tasks
async function loadTasks() {
    const response = await fetch(apiUrl, { method: "GET" });
    if (response.ok) {
        const tasks = await response.json();
        const taskList = document.getElementById("task-list");
        taskList.innerHTML = "";
        tasks.forEach((task) => {
            const li = document.createElement("li");
            li.textContent = task.name;
            taskList.appendChild(li);
        });
    } else {
        alert("Failed to load tasks.");
    }
}

// Load tasks on page load
loadTasks();
