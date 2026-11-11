#!/bin/bash
# One-time setup: finds your Apple team ID and puts it into BrushBlast.swiftpm/Package.swift
# Run from the TimerApp folder:   bash setup_signing.sh
set -e
cd "$(dirname "$0")"
PKG="BrushBlast.swiftpm/Package.swift"

TEAM=$(security find-certificate -a -c "Apple Development" -p 2>/dev/null \
  | openssl x509 -noout -subject 2>/dev/null \
  | sed -n 's/.*OU *= *\([A-Z0-9]\{10\}\).*/\1/p' | head -1)

if [ -z "$TEAM" ]; then
  echo ""
  echo "❌ Couldn't find an Apple Development certificate on this Mac yet."
  echo "   In Xcode: Xcode → Settings… → Accounts → (your Apple ID) → Manage Certificates… → + → Apple Development"
  echo "   Then run this script again."
  exit 1
fi

USERPART=$(whoami | tr -cd 'a-zA-Z0-9' | tr 'A-Z' 'a-z')
BUNDLE="com.${USERPART:-me}.brushblast"

sed -i '' "s/teamIdentifier: \"[^\"]*\"/teamIdentifier: \"$TEAM\"/" "$PKG"
sed -i '' "s/bundleIdentifier: \"[^\"]*\"/bundleIdentifier: \"$BUNDLE\"/" "$PKG"

echo ""
echo "✅ Team ID:          $TEAM"
echo "✅ Bundle ID:        $BUNDLE"
echo "✅ Updated $PKG"
echo ""
echo "Opening Xcode — pick your iPhone at the top and press ▶ Run."
open BrushBlast.swiftpm
