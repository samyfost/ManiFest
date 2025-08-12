# 🎭 ManiFest – Festival Management System

**ManiFest** is an application for creating, managing, and organizing festivals.  
It supports multiple user roles, automated notifications, and integration with RabbitMQ for event-based messaging.

---

## 🚀 Features
- Create and manage festivals with full CRUD functionality.
- Role-based access:
  - **Admin** – Full control over all data.
  - **Regular User** – Can browse and buy tickets for festivals.
- Automatic email notifications via **RabbitMQ** whenever a festival is created.
- Modern and responsive UI for a smooth user experience.

---

## 🔑 Login Credentials

| Role            | Username | Password |
|-----------------|----------|----------|
| **Admin**       | admin    | test     |
| **Regular User**| user     | test     |

---

## 📧 RabbitMQ Email Testing

The application integrates with **RabbitMQ** to send a test email every time a new festival is created.

| Service  | Email                         | Password          |
|----------|-------------------------------|-------------------|
| RabbitMQ | receiver.manifest@gmail.com   | manifesttest123   |