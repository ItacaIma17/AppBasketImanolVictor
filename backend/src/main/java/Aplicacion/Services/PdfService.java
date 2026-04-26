package Aplicacion.Services;

import Presentacion.DTOS.Arbitro.ActaResponseDTO;
import com.itextpdf.kernel.colors.ColorConstants;
import com.itextpdf.kernel.font.PdfFont;
import com.itextpdf.kernel.font.PdfFontFactory;
import com.itextpdf.kernel.pdf.PdfDocument;
import com.itextpdf.kernel.pdf.PdfWriter;
import com.itextpdf.layout.Document;
import com.itextpdf.layout.element.Cell;
import com.itextpdf.layout.element.Paragraph;
import com.itextpdf.layout.element.Table;
import com.itextpdf.layout.properties.TextAlignment;
import com.itextpdf.layout.properties.UnitValue;
import org.springframework.stereotype.Service;
import java.io.ByteArrayOutputStream;
import java.io.IOException;

@Service
public class PdfService {

    public byte[] generarActaPdf(ActaResponseDTO acta) throws IOException {
        ByteArrayOutputStream outputStream = new ByteArrayOutputStream();

        // Crear el documento PDF
        PdfWriter writer = new PdfWriter(outputStream);
        PdfDocument pdfDoc = new PdfDocument(writer);
        Document document = new Document(pdfDoc);

        // Crear fuente
        PdfFont font = PdfFontFactory.createFont();

        // Título
        Paragraph titulo = new Paragraph("ACTA DE PARTIDO")
                .setFont(font)
                .setFontSize(20)
                .setBold()
                .setTextAlignment(TextAlignment.CENTER);
        document.add(titulo);

        document.add(new Paragraph(" ")); // Espacio

        // Información del partido
        document.add(new Paragraph("Fecha: " + acta.getFechaActa().toString()).setFont(font));
        document.add(new Paragraph("Árbitro: " + acta.getArbitroNombre()).setFont(font));
        document.add(new Paragraph("Equipo Local: " + acta.getEquipoLocal()).setFont(font));
        document.add(new Paragraph("Equipo Visitante: " + acta.getEquipoVisitante()).setFont(font));
        document.add(new Paragraph("Resultado: " + acta.getResultadoLocal() + " - " + acta.getResultadoVisitante()).setFont(font));

        document.add(new Paragraph(" ")); // Espacio

        // Tabla de eventos
        float[] columnWidths = {2, 3, 2, 2, 3};
        Table table = new Table(UnitValue.createPercentArray(columnWidths));
        table.setWidth(UnitValue.createPercentValue(100));

        // Headers
        table.addHeaderCell(new Cell().add(new Paragraph("Minuto").setBold().setFont(font)));
        table.addHeaderCell(new Cell().add(new Paragraph("Equipo").setBold().setFont(font)));
        table.addHeaderCell(new Cell().add(new Paragraph("Jugador").setBold().setFont(font)));
        table.addHeaderCell(new Cell().add(new Paragraph("Tipo").setBold().setFont(font)));
        table.addHeaderCell(new Cell().add(new Paragraph("Descripción").setBold().setFont(font)));

        // Eventos
        for (ActaResponseDTO.EventoResponseDTO evento : acta.getEventos()) {
            table.addCell(new Cell().add(new Paragraph(String.valueOf(evento.getMinuto())).setFont(font)));
            table.addCell(new Cell().add(new Paragraph(evento.getNombreEquipo()).setFont(font)));
            table.addCell(new Cell().add(new Paragraph(evento.getNombreJugador()).setFont(font)));
            table.addCell(new Cell().add(new Paragraph(evento.getTipo()).setFont(font)));
            table.addCell(new Cell().add(new Paragraph(evento.getDescripcion() != null ? evento.getDescripcion() : "").setFont(font)));
        }

        document.add(table);

        // Observaciones
        if (acta.getObservaciones() != null && !acta.getObservaciones().isEmpty()) {
            document.add(new Paragraph(" ")); // Espacio
            document.add(new Paragraph("Observaciones:").setBold().setFont(font));
            document.add(new Paragraph(acta.getObservaciones()).setFont(font));
        }

        // Cerrar documento
        document.close();

        return outputStream.toByteArray();
    }
}