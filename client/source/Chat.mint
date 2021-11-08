component Chat {
  connect Api exposing { ws }
  connect Messages exposing { list, update }
  connect Theme exposing { theme }
  connect Characters exposing { character }

  property room : Room
  property roomKey : String
  state socket : Maybe(WebSocket) = Maybe::Nothing
  state shouldConnect = true

  use Provider.WebSocket {
    url = "#{ws}/chat/#{room.id}?key=#{roomKey}",
    reconnectOnClose = true,
    onMessage = handleMessage,
    onError = handleError,
    onClose = handleClose,
    onOpen = handleOpen
  } when {
    shouldConnect
  }

  fun handleMessage(data: String) {
    try {
      object = Json.parse(data) |> Maybe.toResult("Decode Error")
      action = MessageAction.In.fromObject(object)

      update(action, room)
    }

    catch Object.Error => err {
      sequence {
        err |> Debug.log
        next {}
      }
    } catch String => err {
      sequence {
        err |> Debug.log
        next {}
      }
    }
  }

  fun handleError {
    sequence {
      void
    }
  }
  fun handleClose {
    next {
      socket = Maybe::Nothing
    }
  }
  fun handleOpen(socket : WebSocket) {
    next {
      socket = Maybe::Just(socket)
    }
  }

  style chat {
    flex-grow: 1;
    background-color: #{theme.chat.background};
    overflow-x: hidden;
    overflow-y: scroll;
    padding: 0.8rem 1rem 3rem 1rem;
  }

  style messages {
    color: #{theme.chat.textColor};
    list-style: none;
    padding: 0px;
    display: grid;
    grid-template-columns: 6rem 1fr;
    grid-gap: 0px;
  }

  style message {
    display: contents;
    word-break: break-word;
  }

  fun render {
    <section::chat>
      <Chat.Input username={character.name} socket={socket} />
      <ol::messages>
      for (msg of Array.reverse(list |> Map.get(room) |> Maybe.withDefault([]))) {
          <li::message><MessageDisplay data={msg} /></li>
        }
      </ol>
    </section>
  }
}
