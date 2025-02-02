<%@ page language="java" import="utility.*, java.util.Vector" %>
<%
	WebInterface WI = new WebInterface(request);
%>
<style type="text/css">
a:hover {
	font-weight: bolder;
}
a:link {
	color: #FFFFFF;
}
a:active {
	color: #FFFFFF;
}
a:visited {
	color: #FFFFFF;
}</style>
<%
int iPgIndex = Integer.parseInt(request.getParameter("pgIndex"));
 %>    <table border="0" cellpadding="0" cellspacing="0" bgcolor="#D2AE72" height="30" width="100%">
      <tr>		
<%if(iPgIndex == 0){%>
        <td width="20%" bgcolor="#FF0000" align="center" class="thinborderBOTTOM"><strong><font color="#FFFFFF">MANAGE SPONSOR</font></strong></td>
<%}else{%>
        <td width="20%" bgcolor="#FFCC99" align="center" class="thinborderBOTTOM"><a href="manage_sponsor.jsp?pgIndex=0">
			<strong><font color="#000000">MANAGE SPONSOR</font></strong></a></td>		
<%}if(iPgIndex == 1){%>
        <td width="20%" align="center" bgcolor="#FF0000" class="thinborderBOTTOM"><strong><font color="#FFFFFF">MANAGE STUDENT</font></strong></td>
<%}else{%>
        <td width="20%" bgcolor="#FFCC99" align="center" class="thinborderBOTTOM"><a href="manage_student.jsp?pgIndex=1">
			<strong><font color="#000000">MANAGE STUDENT</font></strong></a></td>
<%}
if(iPgIndex == 2){%>
        <td width="20%" align="center" bgcolor="#FF0000" class="thinborderBOTTOM"><strong><font color="#FFFFFF">COPY SPONSORED STUDENTS</font></strong></td>
<%}else{%>
        <td width="20%" bgcolor="#FFCC99" align="center" class="thinborderBOTTOM"><a href="copy_sponsored_student.jsp?pgIndex=2">
			<strong><font color="#000000">COPY SPONSORED STUDENTS</font></strong></a></td>
<%}%>
		
	</tr>
</table>
