const express = require('express');
const socketio = require('socket.io');
const http = require('http');
const cors = require('cors');
const { addUser, removeUser, getUser, getUsersInRoom } = require('./users');
const path = require('path');

const PORT = process.env.PORT || 5002;

const app = express();
const server = http.createServer(app);
const io = socketio(server);

app.use(cors());

const handleJoin = (socket) => (payload, callback) => {
    const numberOfUsersInRoom = getUsersInRoom(payload.room).length;
    const { error, newUser } = addUser({
        id: socket.id,
        name: numberOfUsersInRoom === 0 ? 'Player 1' : 'Player 2',
        room: payload.room,
    });

    if (error) return callback(error);

    socket.join(newUser.room);
    io.to(newUser.room).emit('roomData', { room: newUser.room, users: getUsersInRoom(newUser.room) });
    socket.emit('currentUserData', { name: newUser.name });
    callback();
};

const handleInitGameState = (socket) => (gameState) => {
    const user = getUser(socket.id);
    if (user) io.to(user.room).emit('initGameState', gameState);
};

const handleUpdateGameState = (socket) => (gameState) => {
    const user = getUser(socket.id);
    if (user) io.to(user.room).emit('updateGameState', gameState);
};

const handleSendMessage = (socket) => (payload, callback) => {
    const user = getUser(socket.id);
    io.to(user.room).emit('message', { user: user.name, text: payload.message });
    callback();
};

const handleDisconnect = (socket) => () => {
    const user = removeUser(socket.id);
    if (user) io.to(user.room).emit('roomData', { room: user.room, users: getUsersInRoom(user.room) });
};

io.on('connection', (socket) => {
    socket.on('join', handleJoin(socket));
    socket.on('initGameState', handleInitGameState(socket));
    socket.on('updateGameState', handleUpdateGameState(socket));
    socket.on('sendMessage', handleSendMessage(socket));
    socket.on('disconnected', handleDisconnect(socket));
});

// Serve static assets in production
if (process.env.NODE_ENV === 'production') {
    app.use(express.static('client/build'));
    app.get('*', (req, res) => {
        res.sendFile(path.resolve(__dirname, 'client', 'build', 'index.html'));
    });
}

server.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
});