from __future__ import annotations

from .discord_messages import panel_embed
from .discord_rest import DiscordRestClient
from .errors import ValidationError
from .service import VendingService


class PanelManager:
    def __init__(self, service: VendingService, discord: DiscordRestClient):
        self.service = service
        self.discord = discord

    def publish(self, actor_id: str, *, channel_id: str | None = None) -> str:
        if not self.service.validate_admin_id(actor_id):
            raise ValidationError("administrator permission is required")
        destination = channel_id or self.service.settings.discord_panel_channel_id
        if not destination:
            raise ValidationError("panel channel is not configured")
        embed = panel_embed()
        try:
            response = self.discord.publish_panel(destination, None, embeds=[embed])
        except TypeError as exc:
            if "embed" not in str(exc).lower():
                raise
            response = self.discord.publish_panel(destination, None)
        payload = response.payload
        if not isinstance(payload, dict) or not payload.get("id"):
            raise ValueError("Discord did not return a panel message")
        self.service.database.set_setting("discord.panel_channel_id", destination)
        self.service.database.set_setting("discord.panel_message_id", str(payload["id"]))
        return str(payload["id"])
