"""Build assets/seed/seed.json — the offline snapshot the app loads on first launch.

Operators, stops, routes, timetable headers (effective dates, official PDF links) and footnotes are
small enough to ship inside the app, so stop search, route browsing and footnote
filtering work on a phone that has never been online.

Run from the repository root with the database container up:

    python mobile/tool/build_seed.py
"""
import hashlib
import json
import pathlib
import subprocess

CONTAINER = "gabs_pg"
OUT = pathlib.Path(__file__).resolve().parents[1] / "assets" / "seed" / "seed.json"


def query(sql: str):
    wrapped = f"SELECT coalesce(json_agg(t), '[]'::json) FROM ({sql}) t"
    out = subprocess.run(
        ["docker", "exec", CONTAINER, "psql", "-U", "gabs", "-d", "gabs", "-Atc", wrapped],
        check=True, capture_output=True, text=True, encoding="utf-8",
    ).stdout
    return json.loads(out)


def main() -> None:
    version = query(
        "SELECT to_char(max(coalesce(parsed_at, scraped_at)) AT TIME ZONE 'UTC',"
        " 'YYYY-MM-DD\"T\"HH24:MI:SS\"Z\"') AS v FROM timetable")[0]["v"]
    seed = {
        "version": version,
        "operators": query("SELECT o.code, o.name, o.kind, count(r.id) AS routes FROM operator o"
                           " LEFT JOIN route r ON r.operator_id = o.id GROUP BY o.id ORDER BY o.id"),
        "stops": query("SELECT s.id, s.name, round(s.lat::numeric, 6) AS lat, round(s.lon::numeric, 6) AS lon,"
                       " o.code AS operator_code, o.kind AS operator_kind"
                       " FROM stop s JOIN operator o ON o.id = s.operator_id"
                       " WHERE s.lat IS NOT NULL ORDER BY s.name, o.id"),
        "routes": query("SELECT r.id, r.name, r.origin, r.destination, r.letter_group, o.code AS operator_code,"
                        " count(t.id) AS timetable_count FROM route r"
                        " JOIN operator o ON o.id = r.operator_id"
                        " LEFT JOIN timetable t ON t.route_id = r.id"
                        " GROUP BY r.id, o.code ORDER BY r.name"),
        "timetables": query("SELECT id, route_id, timetable_number, is_public_holiday,"
                            " effective_from::text, effective_to::text, pdf_url"
                            " FROM timetable WHERE parse_status = 'parsed' ORDER BY id"),
        "notes": query("SELECT timetable_id, code, description FROM timetable_note"
                       " ORDER BY timetable_id, code"),
    }
    # The newest timetable date alone does not change when an operator is added whose
    # timetables carry no dates (MyCiTi), so the version also carries a content hash; the
    # app reloads its bundled data whenever the version differs from what it has.
    body = json.dumps({k: v for k, v in seed.items() if k != "version"}, separators=(",", ":"))
    seed["version"] = f"{version}+{hashlib.sha1(body.encode('utf-8')).hexdigest()[:10]}"
    version = seed["version"]
    OUT.write_text(json.dumps(seed, separators=(",", ":")), encoding="utf-8")
    print(f"{OUT}: version {version}, {len(seed['operators'])} operators, {len(seed['stops'])} stops, {len(seed['routes'])} routes, "
          f"{len(seed['timetables'])} timetables, {len(seed['notes'])} notes, "
          f"{OUT.stat().st_size // 1024} KB")


if __name__ == "__main__":
    main()
