#!/bin/bash

# Diátaxis Documentation Analysis Pipeline
# Analyzes documentation for completeness, consistency, and categorization

set -e

DOCS_DIR="docs"
REPORT_FILE="docs-analysis-report.md"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}       Diátaxis Documentation Analysis Pipeline            ${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo ""

# Initialize counters
tutorials=0
howto=0
reference=0
explanation=0
missing_frontmatter=0
draft_count=0
ai_generated=0
needs_review=0

# Initialize report
cat > "$REPORT_FILE" << 'EOF'
# Documentation Analysis Report

Generated: $(date +%Y-%m-%d\ %H:%M:%S)

## Summary

EOF

echo "## Summary" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

# Function to extract frontmatter field
get_frontmatter_field() {
    local file=$1
    local field=$2
    grep -m1 "^${field}:" "$file" 2>/dev/null | sed "s/${field}:[[:space:]]*//" | tr -d '"' || echo ""
}

# Function to check if file has frontmatter
has_frontmatter() {
    head -1 "$1" | grep -q "^---$"
}

echo -e "${YELLOW}Scanning documentation...${NC}"
echo ""

# Scan each quadrant
for quadrant in tutorials how-to reference explanation; do
    dir="$DOCS_DIR/$quadrant"
    if [ -d "$dir" ]; then
        count=$(find "$dir" -name "*.md" 2>/dev/null | wc -l | tr -d ' ')
        case $quadrant in
            tutorials) tutorials=$count ;;
            how-to) howto=$count ;;
            reference) reference=$count ;;
            explanation) explanation=$count ;;
        esac
        echo -e "  ${GREEN}✓${NC} $quadrant: $count documents"
    else
        echo -e "  ${RED}✗${NC} $quadrant: directory missing"
    fi
done

total=$((tutorials + howto + reference + explanation))
echo ""
echo -e "${BLUE}Total documents: $total${NC}"
echo ""

# Analyze each document
echo -e "${YELLOW}Analyzing document quality...${NC}"
echo ""

echo "## Document Inventory" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

for quadrant in tutorials how-to reference explanation; do
    dir="$DOCS_DIR/$quadrant"
    # Use quadrant name as-is for header
    echo "### $quadrant" >> "$REPORT_FILE"
    echo "" >> "$REPORT_FILE"

    if [ -d "$dir" ]; then
        files=$(find "$dir" -name "*.md" 2>/dev/null)
        if [ -n "$files" ]; then
            echo "| Document | Status | Author | Tags |" >> "$REPORT_FILE"
            echo "|----------|--------|--------|------|" >> "$REPORT_FILE"

            for file in $files; do
                filename=$(basename "$file")

                if has_frontmatter "$file"; then
                    status=$(get_frontmatter_field "$file" "status")
                    author=$(get_frontmatter_field "$file" "author")
                    tags=$(get_frontmatter_field "$file" "tags")

                    [ -z "$status" ] && status="unknown"
                    [ -z "$author" ] && author="unknown"
                    [ -z "$tags" ] && tags="-"

                    echo "| $filename | $status | $author | $tags |" >> "$REPORT_FILE"

                    # Count stats
                    [ "$status" = "draft" ] && ((draft_count++)) || true
                    [ "$status" = "review" ] && ((needs_review++)) || true
                    [[ "$author" == *"AI"* ]] && ((ai_generated++)) || true
                else
                    echo "| $filename | ⚠️ NO FRONTMATTER | - | - |" >> "$REPORT_FILE"
                    ((missing_frontmatter++)) || true
                    echo -e "  ${RED}⚠${NC}  Missing frontmatter: $file"
                fi
            done
            echo "" >> "$REPORT_FILE"
        else
            echo "_No documents yet_" >> "$REPORT_FILE"
            echo "" >> "$REPORT_FILE"
        fi
    fi
done

# Coverage analysis
echo "## Coverage Analysis" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

echo "| Quadrant | Count | Percentage |" >> "$REPORT_FILE"
echo "|----------|-------|------------|" >> "$REPORT_FILE"

if [ $total -gt 0 ]; then
    echo "| Tutorials | $tutorials | $((tutorials * 100 / total))% |" >> "$REPORT_FILE"
    echo "| How-to Guides | $howto | $((howto * 100 / total))% |" >> "$REPORT_FILE"
    echo "| Reference | $reference | $((reference * 100 / total))% |" >> "$REPORT_FILE"
    echo "| Explanation | $explanation | $((explanation * 100 / total))% |" >> "$REPORT_FILE"
else
    echo "| Tutorials | 0 | 0% |" >> "$REPORT_FILE"
    echo "| How-to Guides | 0 | 0% |" >> "$REPORT_FILE"
    echo "| Reference | 0 | 0% |" >> "$REPORT_FILE"
    echo "| Explanation | 0 | 0% |" >> "$REPORT_FILE"
fi
echo "" >> "$REPORT_FILE"

# Recommendations
echo "## Recommendations" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

if [ $tutorials -eq 0 ]; then
    echo "- ⚠️ **No tutorials** - Add getting-started tutorials for newcomers" >> "$REPORT_FILE"
fi
if [ $explanation -eq 0 ]; then
    echo "- ⚠️ **No explanations** - Add architectural context and rationale docs" >> "$REPORT_FILE"
fi
if [ $missing_frontmatter -gt 0 ]; then
    echo "- 🔧 **$missing_frontmatter docs missing frontmatter** - Add required metadata" >> "$REPORT_FILE"
fi
if [ $ai_generated -gt 0 ] && [ $needs_review -gt 0 ]; then
    echo "- 👀 **$needs_review docs need human review** - Verify AI-generated content" >> "$REPORT_FILE"
fi

# Balance check
if [ $total -gt 0 ]; then
    min_pct=15
    if [ $((tutorials * 100 / total)) -lt $min_pct ]; then
        echo "- 📚 Tutorials underrepresented (<${min_pct}%)" >> "$REPORT_FILE"
    fi
    if [ $((howto * 100 / total)) -lt $min_pct ]; then
        echo "- 📚 How-to guides underrepresented (<${min_pct}%)" >> "$REPORT_FILE"
    fi
    if [ $((reference * 100 / total)) -lt $min_pct ]; then
        echo "- 📚 Reference docs underrepresented (<${min_pct}%)" >> "$REPORT_FILE"
    fi
    if [ $((explanation * 100 / total)) -lt $min_pct ]; then
        echo "- 📚 Explanation docs underrepresented (<${min_pct}%)" >> "$REPORT_FILE"
    fi
fi

echo "" >> "$REPORT_FILE"
echo "---" >> "$REPORT_FILE"
echo "_Report generated by analyze-docs.sh_" >> "$REPORT_FILE"

# Print summary
echo ""
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}                      Summary                              ${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "  Total documents:        $total"
echo -e "  Draft status:           $draft_count"
echo -e "  Needs review:           $needs_review"
echo -e "  AI-generated:           $ai_generated"
echo -e "  Missing frontmatter:    $missing_frontmatter"
echo ""
echo -e "${GREEN}Report written to: $REPORT_FILE${NC}"
echo ""
