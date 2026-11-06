const http = require('node:http');

const PORT = process.env.PORT || 8080;

const server = http.createServer((req, res) => {

    if (req.method === 'GET' && req.url === '/') {

        res.writeHead(200, {
            'Content-Type': 'application/json'
        });

        res.end(JSON.stringify({
            message: 'Hello from DevOps Intern Task!',
            status: 'running'
        }));

        return;
    }

    res.writeHead(404, {
        'Content-Type': 'application/json'
    });

    res.end(JSON.stringify({
        message: 'Route not found',
        status: 'error'
    }));
});

server.listen(PORT, '0.0.0.0', () => {
    console.log(`Server is running on port ${PORT}`);
});