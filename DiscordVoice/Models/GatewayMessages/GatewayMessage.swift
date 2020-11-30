//
//  GatewayMessage.swift
//  DiscordVoice
//
//  Created by Patrick Gatewood on 11/24/20.
//

import Foundation

/// Used for both sending and receiving messages to/from Discord over the web socket.
/// https://discord.com/developers/docs/topics/gateway#payloads
struct GatewayMessage: Codable {
    let opCode: Payload.OpCode
    let payload: Payload?
    let sequenceNumber: Int?
    let eventType: DiscordEventType?
    
    enum CodingKeys: String, CodingKey {
        case opCode = "op"
        case payload = "d"
        case sequenceNumber = "s"
        case eventType = "t"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        opCode = try container.decode(Payload.OpCode.self, forKey: .opCode)
        sequenceNumber = try? container.decode(Int.self, forKey: .sequenceNumber)
        eventType = try? container.decode(DiscordEventType.self, forKey: .eventType)
        
        switch opCode {
        case .dispatch:
            switch eventType {
            case .guildCreate:
                let guild = try container.decode(GuildPayload.self, forKey: .payload)
                payload = .dispatch(.guildCreate(guild))
            case .ready:
                let readyPayload = try container.decode(ReadyPayload.self, forKey: .payload)
                payload = .dispatch(.ready(readyPayload))
            case .none:
                throw NSError() // TODO throw real errors
            }
        case .heartbeat:
            payload = .heartbeat(try container.decode(HeartbeatPayload.self, forKey: .payload))
        case .identify:
            throw NSError() // TODO this is only a sent message. how to handle
        case .hello:
            payload = .hello(try container.decode(HelloPayload.self, forKey: .payload))
        case .heartbeatAcknowledged:
            payload = nil
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(opCode, forKey: .opCode)
        
        try? container.encode(sequenceNumber, forKey: .sequenceNumber)
        try? container.encode(eventType, forKey: .eventType)
        
        switch payload {
        case .dispatch:
            throw NSError() // TODO this should only be received never sent right?
        case .heartbeat(let payload):
            try container.encode(payload, forKey: .payload)
        case .identity(let payload):
            try container.encode(payload, forKey: .payload)
        case .hello(let payload):
            try container.encode(payload, forKey: .payload)
        case .unknown, .none:
            throw NSError() // TODO
        }
    }
    
    init(opCode: Payload.OpCode, payload: Payload) {
        self.opCode = opCode
        self.payload = payload
        self.sequenceNumber = nil
        self.eventType = nil
    }
}
