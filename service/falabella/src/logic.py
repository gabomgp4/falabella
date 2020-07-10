def get_payload_stats(payload: str):
    return {
        "length": len(payload),
        "versions": {
            "lower": payload.lower(),
            "upper": payload.upper(),
            "caseFold": payload.casefold(),
            "capitalize": payload.capitalize()
        },
        "payload": payload
    }
