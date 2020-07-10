from falabella.src.logic import get_payload_stats


def test_get_payload_stats():
    stats = get_payload_stats("Gabriel Gómez")
    assert stats["length"] == 13
    assert stats["payload"] == "Gabriel Gómez"
    assert stats["versions"]["lower"] == "gabriel gómez"
    assert stats["versions"]["upper"] == "GABRIEL GÓMEZ"
    assert stats["versions"]["caseFold"] == "gabriel gómez"
    assert stats["versions"]["capitalize"] == "Gabriel gómez"
