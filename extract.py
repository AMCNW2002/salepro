import sys, re, json

def extract_method(content, method_name):
    pattern = r'\s+Widget ' + method_name + r'\s*\('
    match = re.search(pattern, content)
    if not match:
        return None, content

    start_idx = match.start()
    brace_idx = content.find('{', start_idx)
    if brace_idx == -1: return None, content
    
    open_braces = 1
    idx = brace_idx + 1
    in_string = False
    escape = False
    
    while open_braces > 0 and idx < len(content):
        c = content[idx]
        if escape:
            escape = False
        elif c == '\\':
            escape = True
        elif c == '\'' or c == '\"':
            in_string = not in_string
        elif not in_string:
            if c == '{': open_braces += 1
            elif c == '}': open_braces -= 1
        idx += 1
        
    end_idx = idx
    method_code = content[start_idx:end_idx]
    new_content = content[:start_idx] + content[end_idx:]
    return method_code, new_content

def process_file():
    path = r'c:\Users\User\Desktop\New folder\salepro\lib\screens\admin\admin_reports_screen.dart'
    with open(path, 'r', encoding='utf-8') as f:
        content = f.read()

    methods = {
        'sales': ['_buildSalesReportsSection', '_buildCreativeSalesSummary', '_buildSleekMetricCard', '_buildCreativeSalesTrend', '_buildCreativeTopProducts'],
        'route': ['_buildRouteAnalyticsSection', '_buildCreativeRouteSummaryCards', '_buildCreativeRouteRanking', '_buildCreativeRouteComparison', '_buildCreativeCustomerCoverage', '_buildCreativeRepRouteAssignment'],
        'rep': ['_buildRepAnalyticsSection', '_buildCreativeRepSummaryCards', '_buildCreativeRepRanking', '_buildCreativeRepVisitPerformance', '_buildCreativeRepPerformanceDetails', '_buildMiniStat'],
        'financial': ['_buildFinancialAnalyticsSection', '_buildSleekFinancialKPIs', '_buildModernIncomeExpense', '_buildRecentTransactionsList', '_buildOutstandingDebtsList', '_buildFinancialFilters'],
        'export': ['_buildExportCenter', '_buildExportCard']
    }

    extracted = {k: [] for k in methods}

    for category, method_list in methods.items():
        for m in method_list:
            code, content = extract_method(content, m)
            if code:
                extracted[category].append(code)
            else:
                print(f'Method not found: {m}')

    with open('extracted_methods.json', 'w', encoding='utf-8') as f:
        json.dump(extracted, f)

    with open(path + '.temp', 'w', encoding='utf-8') as f:
        f.write(content)

process_file()
print('Extraction complete')
