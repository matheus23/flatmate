import "./requestIdleCallback.js"

export async function start({ bpm, onBeat }) {
    const beatDelay = 60000 / bpm

    while (true) {
        await untilIdle()
        await onBeat()
        await pause(beatDelay)

        if (document.hidden) {
            await untilWindowVisible()
        }
    }
}


function pause(ms) {
    return new Promise(resolve => setTimeout(resolve, ms))
}

function untilIdle() {
    return new Promise(resolve => window.requestIdleCallback(resolve))
}

function untilWindowVisible() {
    if (!document.hidden) {
        return new Promise(resolve => resolve())
    }

    return new Promise(resolve => {
        function listener() {
            document.removeEventListener("visibilitychange", listener)
            resolve()
        }

        document.addEventListener("visibilitychange", listener)
    })
}
