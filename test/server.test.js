
const test = require('node:test');
const assert = require('node:assert/strict');

const { createServer } = require('../src/server');

async function startTestServer(t) {
    const server = createServer();

    await new Promise((resolve, reject) => {
        server.once('error', reject);
        server.listen(0, '127.0.0.1', resolve);
    });

    t.after(() => new Promise((resolve, reject) => {
        server.close(error => {
            if (error) reject(error);
            else resolve();
        });
    }));

    return `http://127.0.0.1:${server.address().port}`;
}

test('GET / should return correct JSON response', async (t) => {
    const baseUrl = await startTestServer(t);

    const response = await fetch(`${baseUrl}/`);

    assert.equal(response.status, 200);
    assert.match(
        response.headers.get('content-type'),
        /application\/json/
    );

    const data = await response.json();

    assert.deepEqual(data, {
        message: 'Hello from DevOps Intern Task!',
        status: 'running'
    });
});

test('Unknown route should return 404', async (t) => {
    const baseUrl = await startTestServer(t);

    const response = await fetch(`${baseUrl}/unknown`);

    assert.equal(response.status, 404);

    const data = await response.json();

    assert.deepEqual(data, {
        message: 'Route not found',
        status: 'error'
    });
});

test('POST / should return 404', async (t) => {
    const baseUrl = await startTestServer(t);

    const response = await fetch(`${baseUrl}/`, {
        method: 'POST'
    });

    assert.equal(response.status, 404);
});
