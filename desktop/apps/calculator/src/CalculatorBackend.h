#pragma once

#include <QObject>
#include <QStringList>
#include <memory>

class Calculator;

class CalculatorBackend final : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString result READ result NOTIFY resultChanged)
    Q_PROPERTY(QString errorText READ errorText NOTIFY errorTextChanged)
    Q_PROPERTY(QStringList history READ history NOTIFY historyChanged)
    Q_PROPERTY(bool degreeMode READ degreeMode WRITE setDegreeMode NOTIFY degreeModeChanged)

public:
    explicit CalculatorBackend(QObject *parent = nullptr);
    ~CalculatorBackend() override;

    QString result() const { return m_result; }
    QString errorText() const { return m_errorText; }
    QStringList history() const { return m_history; }
    bool degreeMode() const { return m_degreeMode; }

    void setDegreeMode(bool enabled);

    Q_INVOKABLE QString evaluate(const QString &expression);
    Q_INVOKABLE QString convert(const QString &value, const QString &fromUnit, const QString &toUnit);
    Q_INVOKABLE QString formatBase(const QString &expression, const QString &baseName);
    Q_INVOKABLE void clearHistory();
    Q_INVOKABLE void copyResult();

signals:
    void resultChanged();
    void errorTextChanged();
    void historyChanged();
    void degreeModeChanged();

private:
    QString calculate(const QString &expression, bool remember);
    void setResult(const QString &value);
    void setError(const QString &value);
    void addHistory(const QString &expression, const QString &value);
    void loadState();
    void saveState() const;

    std::unique_ptr<Calculator> m_calculator;
    QString m_result;
    QString m_errorText;
    QStringList m_history;
    bool m_degreeMode = true;
};
