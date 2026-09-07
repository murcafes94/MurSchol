#include "CalculatorBackend.h"

#include <libqalculate/Calculator.h>
#include <libqalculate/includes.h>

#include <QClipboard>
#include <QGuiApplication>
#include <QSettings>

CalculatorBackend::CalculatorBackend(QObject *parent)
    : QObject(parent),
      m_calculator(std::make_unique<Calculator>())
{
    m_calculator->loadGlobalDefinitions();
    m_calculator->loadLocalDefinitions();
    loadState();
}

CalculatorBackend::~CalculatorBackend() = default;

void CalculatorBackend::setDegreeMode(bool enabled)
{
    if (m_degreeMode == enabled)
        return;
    m_degreeMode = enabled;
    saveState();
    emit degreeModeChanged();
}

QString CalculatorBackend::evaluate(const QString &expression)
{
    return calculate(expression, true);
}

QString CalculatorBackend::convert(const QString &value, const QString &fromUnit, const QString &toUnit)
{
    const QString amount = value.trimmed();
    const QString from = fromUnit.trimmed();
    const QString to = toUnit.trimmed();
    if (amount.isEmpty() || from.isEmpty() || to.isEmpty()) {
        setError(QStringLiteral("Escribe un valor y selecciona las dos unidades."));
        return {};
    }
    return calculate(QStringLiteral("%1 %2 to %3").arg(amount, from, to), true);
}

QString CalculatorBackend::formatBase(const QString &expression, const QString &baseName)
{
    const QString value = expression.trimmed();
    if (value.isEmpty()) {
        setError(QStringLiteral("Escribe primero una expresión."));
        return {};
    }

    QString target;
    const QString base = baseName.trimmed().toLower();
    if (base == QStringLiteral("bin") || base == QStringLiteral("binary"))
        target = QStringLiteral("binary");
    else if (base == QStringLiteral("oct") || base == QStringLiteral("octal"))
        target = QStringLiteral("octal");
    else if (base == QStringLiteral("hex") || base == QStringLiteral("hexadecimal"))
        target = QStringLiteral("hexadecimal");
    else
        target = QStringLiteral("decimal");

    return calculate(QStringLiteral("%1 to %2").arg(value, target), true);
}

void CalculatorBackend::clearHistory()
{
    if (m_history.isEmpty())
        return;
    m_history.clear();
    saveState();
    emit historyChanged();
}

void CalculatorBackend::copyResult()
{
    if (!m_result.isEmpty())
        QGuiApplication::clipboard()->setText(m_result);
}

QString CalculatorBackend::calculate(const QString &expression, bool remember)
{
    const QString cleaned = expression.trimmed();
    if (cleaned.isEmpty()) {
        setError(QStringLiteral("Escribe una expresión."));
        return {};
    }

    try {
        EvaluationOptions options = default_user_evaluation_options;
        options.parse_options.angle_unit = m_degreeMode ? ANGLE_UNIT_DEGREES : ANGLE_UNIT_RADIANS;

        const std::string input = m_calculator->unlocalizeExpression(cleaned.toStdString());
        const std::string output = m_calculator->calculateAndPrint(input, 3000, options);
        const QString value = QString::fromStdString(output).trimmed();

        if (value.isEmpty()) {
            setError(QStringLiteral("No se pudo calcular la expresión."));
            return {};
        }

        setError({});
        setResult(value);
        if (remember)
            addHistory(cleaned, value);
        return value;
    } catch (...) {
        setError(QStringLiteral("La expresión no es válida o no pudo evaluarse."));
        return {};
    }
}

void CalculatorBackend::setResult(const QString &value)
{
    if (m_result == value)
        return;
    m_result = value;
    emit resultChanged();
}

void CalculatorBackend::setError(const QString &value)
{
    if (m_errorText == value)
        return;
    m_errorText = value;
    emit errorTextChanged();
}

void CalculatorBackend::addHistory(const QString &expression, const QString &value)
{
    const QString entry = expression + QStringLiteral("\n= ") + value;
    if (!m_history.isEmpty() && m_history.constFirst() == entry)
        return;

    m_history.prepend(entry);
    while (m_history.size() > 50)
        m_history.removeLast();
    saveState();
    emit historyChanged();
}

void CalculatorBackend::loadState()
{
    QSettings settings(QStringLiteral("MurSchol"), QStringLiteral("Calculator"));
    m_history = settings.value(QStringLiteral("history")).toStringList();
    m_degreeMode = settings.value(QStringLiteral("degreeMode"), true).toBool();
}

void CalculatorBackend::saveState() const
{
    QSettings settings(QStringLiteral("MurSchol"), QStringLiteral("Calculator"));
    settings.setValue(QStringLiteral("history"), m_history);
    settings.setValue(QStringLiteral("degreeMode"), m_degreeMode);
}
