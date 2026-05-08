# Usar imagen oficial de Flutter
FROM flutter:3.19.0

# Establecer directorio de trabajo
WORKDIR /app

# Copiar archivos de dependencias
COPY pubspec.yaml pubspec.lock* ./

# Instalar dependencias
RUN flutter pub get

# Copiar el resto del código
COPY . .

# Exponer el puerto para desarrollo web
EXPOSE 5000

# Comando para ejecutar la app en modo desarrollo
CMD ["flutter", "run", "-d", "web-server", "--web-port", "5000", "--web-renderer", "html", "--web-hostname", "0.0.0.0"]