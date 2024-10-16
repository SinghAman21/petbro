<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.pet.pet.CalendarUtil" %>
<%@ page import="com.pet.pet.Event" %>
<%@ page import="java.util.*" %>
<%@ page import="com.google.gson.Gson" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>PetBro - Appointments</title>
    <link href="https://api.fontshare.com/v2/css?f[]=satoshi@1&display=swap" rel="stylesheet">
    <script src="https://cdn.tailwindcss.com"></script>
    <style>
        body {
            font-family: 'satoshi', sans-serif;
            background: #000;
            color: #eee;
            width: 100%;
            min-height: 100vh;
        }

        header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 1.5rem;
            background: #000;
        }

        .border-one {
            border: 0.1px solid #ffffff20;
        }

        .mid {
            border-radius: 32px;
            font-weight: 500;
            background: #ffffff20;
        }

        .mid a {
            color: #fff;
            text-decoration: none;
            padding: 0.8em 1.2em;
            border-radius: 32px;
            width: 7rem;
            text-align: center;
            transition: color 0.3s ease;
        }

        .mid a.active {
            background: #ffffff;
            color: black;
            font-weight: bold;
        }

        .active-day {
            background-color: rgba(0, 255, 136, 0.3);
        }

        .day {
            border-radius: 8px; /* Soft rounded corners */
            border: none;
            background-color: #ffffff12;
            color: #eee; /* Soft text color */
            transition: background-color 0.3s ease; /* Smooth transition */
        }

        .day:hover {
            background-color: #ffffff18; /* Slightly lighter on hover */
        }

        .appointment-card {
            background-color: #1f1f1f;
            border-radius: 12px;
            padding: 1.5rem;
            color: #eee;
            margin-top: 1rem;
            box-shadow: 0 8px 16px rgba(0, 0, 0, 0.5);
            transition: all 0.3s ease;
        }

        .appointment-card:hover {
            transform: translateY(-5px);
        }

        .appointment-title {
            font-size: 1.5rem;
            font-weight: bold;
            margin-bottom: 1rem;
        }

        .appointment-list {
            list-style: none;
            padding: 0;
        }

        .appointment-list li {
            background: rgba(255, 255, 255, 0.08);
            padding: 1rem;
            border-radius: 8px;
            margin-bottom: 0.5rem;
            display: flex;
            justify-content: space-between;
            align-items: center;
            box-shadow: 0 4px 8px rgba(0, 0, 0, 0.3);
            transition: all 0.3s ease;
        }

        .appointment-list li:hover {
            background-color: rgba(255, 255, 255, 0.15);
        }

        .appointment-details {
            display: flex;
            flex-direction: column;
        }

        .appointment-details strong {
            font-size: 1.1rem;
            margin-bottom: 0.2rem;
        }

        .appointment-date {
            font-size: 0.9rem;
            color: #999;
        }

        .appointment-meta {
            font-size: 0.9rem;
            margin-top: 0.5rem;
            color: #ccc;
        }
        /* Toggle button */
        .toggle-button {
            padding: 0.5rem 1rem;
            background: #fff;
            border: none;
            border-radius: 5px;
            color: #000;
            cursor: pointer;
            transition: background 0.3s;
        }

        .toggle-button:hover {
            background: #ffffffba;
        }

        /* Responsive layout */
        .calendar-container {
            display: flex;
            flex-wrap: wrap;
            justify-content: space-between;
            width: 100%;
            flex-direction: column;
            gap: 1rem;
        }

        .calendar-container.minimize {
            gap:0.6em !important;
            flex-direction: row !important;
        }

        .calendar {
            flex: 1; /* Default to full width */
            max-width: 100%; /* Ensures it doesn't exceed the width */
            margin-right: 1rem; /* Space between calendar and appointment card */
        }

        .appointments {
            flex: 1; /* Default to full width */
            max-width: 100%;
        }

        /* Minimize mode */
        .minimize .calendar,
        .minimize .appointments {
            max-width: 50%; /* 50% width in minimize mode */
        }
    </style>
</head>
<body>
<header class="sticky top-0 z-50">
    <div class="left">
        <h1 class="text-2xl font-bold">PetBro</h1>

    </div>
    <div class="mid flex gap-4">
        <a href="/pet_war">Overview</a>
        <a href="${pageContext.request.contextPath}/family">Family</a>
        <a href="${pageContext.request.contextPath}/events" class="active">Sessions</a>
        <a href="#">More</a>
    </div>
    <div class="right">
        <img src="images/user.jpeg" alt="Profile" class="rounded-full w-12 border-one">
    </div>
</header>

<main class="p-6">

    <div class="flex justify-between items-center mb-4">
        <h2 class="text-3xl my-4 text-center font-bold">All Appointments</h2>
        <button class="bg-green-500 hover:bg-green-400 text-black font-bold py-2 px-4 rounded-lg"
                onclick="location.href='/pet_war/appointments'">Add Appointment
        </button>
    </div>

    <div class="text-center mb-4 flex justify-between items-center">
        <h3 class="text-xl mb-4 font-semibold">October 2024</h3>
        <button class="toggle-button" onclick="toggleCalendarMode()">
            <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5"
                 stroke="currentColor" class="size-6">
                <path stroke-linecap="round" stroke-linejoin="round"
                      d="M8.25 15 12 18.75 15.75 15m-7.5-6L12 5.25 15.75 9"/>
            </svg>
        </button>
    </div>

    <div class="calendar-container" id="calendarContainer">
        <div class="calendar" id="calendar">
            <div class="grid grid-cols-7 gap-2">
                <%
                    String[] daysOfWeek = {"Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"};
                    for (String day : daysOfWeek) {
                %>
                <div class="font-bold text-lg"><%= day %>
                </div>
                <% } %>

                <%
                    List<Event> eventsList = (List<Event>) request.getAttribute("eventsList");
                    Map<Integer, List<Event>> appointmentMap = new HashMap<>();
                    for (Event event : eventsList) {
                        Calendar cal = Calendar.getInstance();
                        cal.setTime(event.getDate());
                        int day = cal.get(Calendar.DAY_OF_MONTH);
                        appointmentMap.computeIfAbsent(day, k -> new ArrayList<>()).add(event);
                    }

                    String[][] calendar = CalendarUtil.getCalendar(2024, Calendar.OCTOBER);
                    for (int i = 0; i < calendar.length - 1; i++) {
                        for (int j = 0; j < calendar[i].length; j++) {
                            String day = calendar[i][j];
                %>
                <div class="day border border-gray-700 p-2 cursor-pointer transition hover:bg-gray-600"
                     onclick="showAppointments(<%= day.isEmpty() ? -1 : Integer.parseInt(day) %>)">
                    <%= day.isEmpty() ? "&nbsp;" : day %>
                    <ul class="appointment-list mt-2">
                        <%
                            if (!day.isEmpty()) {
                                int dayNum = Integer.parseInt(day);
                                List<Event> dayAppointments = appointmentMap.get(dayNum);
                                if (dayAppointments != null) {
                                    for (Event event : dayAppointments) {
                        %>
                        <li class="text-sm"><%= event.getPet() %> - <%= event.getVenue() %>
                        </li>
                        <%
                                    }
                                }
                            }
                        %>
                    </ul>
                </div>
                <%
                        }
                    }
                %>
            </div>
        </div>

        <!-- Appointments Card -->
        <!-- Appointments Card -->
        <div class="appointments appointment-card" id="appointmentsCard">
            <div class="appointment-title">Appointments</div>
            <ul class="appointment-list" id="appointmentsList">
                <%
                    for (Event event : eventsList) {
                        Calendar cal = Calendar.getInstance();
                        cal.setTime(event.getDate());
                        int day = cal.get(Calendar.DAY_OF_MONTH);
                        String dateFormatted = day + " October 2024";

                        // Health Checkup, Grooming, and Training Mapping
                        String healthCheckup = Objects.equals(event.getHealthCheckup(), "500") ? "Basic" :
                                (Objects.equals(event.getHealthCheckup(), "1000") ? "Advanced" : "No");
                        String grooming = Objects.equals(event.getGrooming(), "300") ? "Basic" :
                                (Objects.equals(event.getGrooming(), "600") ? "Premium" : "No");
                        String training = Objects.equals(event.getTraining(), "450") ? "Basic" :
                                (Objects.equals(event.getTraining(), "800") ? "Advanced" : "No");
                %>
                <li class="appointment">
                    <div class="appointment-details">
                        <strong><%= event.getPet() %></strong>
                        <span class="appointment-date">Date: <%= dateFormatted %></span>
                        <span class="appointment-date">Venue: <%= event.getVenue() %></span>
                        <div class="appointment-meta">
                            <span>Health Checkup: <%= healthCheckup %></span><br>
                            <span>Grooming: <%= grooming %></span><br>
                            <span>Training: <%= training %></span><br>
                            <span>Reminder: <%= event.getReminder() != null ? event.getReminder() : "No reminder set" %></span>

                        </div>
                    </div>
                </li>
                <%
                    }
                %>
            </ul>
        </div>

</main>

<script>
    let isMaximized = true;

    function toggleCalendarMode() {
        const calendarContainer = document.getElementById('calendarContainer');
        calendarContainer.classList.toggle('minimize');
        isMaximized = !isMaximized;
    }

    function showAppointments(day) {
        if (day === -1) {
            return;
        }
        const appointmentsList = document.getElementById('appointmentsList');
        const events = <%= new Gson().toJson(eventsList) %>;

        // Clear previous appointments
        appointmentsList.innerHTML = "";

        const filteredAppointments = events.filter(event => {
            const eventDate = new Date(event.date);
            return eventDate.getDate() === day && eventDate.getMonth() === 9; // October is month 9 (zero-based)
        });

        // Check if there are any appointments for the selected day
        if (filteredAppointments.length > 0) {
            filteredAppointments.forEach(event => {
                const li = document.createElement('li');
                li.className = 'appointment text-sm';

                const petName = event.pet || "Unknown Pet";
                const venue = event.venue || "Unknown Venue";
                const healthCheckup = event.healthCheckup ? (event.healthCheckup === "500" ? "Basic" : event.healthCheckup === "1000" ? "Advanced" : "No") : "No";
                const grooming = event.grooming ? (event.grooming === "300" ? "Basic" : event.grooming === "600" ? "Premium" : "No") : "No";
                const training = event.training ? (event.training === "450" ? "Basic" : event.training === "800" ? "Advanced" : "No") : "No";
                const reminder = event.reminder || "No reminder set";

                li.innerHTML = `
                <div class="appointment-details">
                    <strong>${petName}</strong>
                    <span class="appointment-date">Date: ${day} October 2024</span>
                    <span class="appointment-date">Venue: ${venue}</span>
                    <div class="appointment-meta">
                        <span>Health Checkup: ${healthCheckup}</span><br>
                        <span>Grooming: ${grooming}</span><br>
                        <span>Training: ${training}</span><br>
                        <span>Reminder: ${reminder}</span>
                    </div>
                </div>
            `;

                appointmentsList.appendChild(li);
            });
        } else {
            appointmentsList.innerHTML = "<li>No appointments for this day.</li>";
        }
    }

</script>
</body>
</html>
