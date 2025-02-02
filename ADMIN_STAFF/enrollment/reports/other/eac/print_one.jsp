<%@ page language="java" import="utility.*,java.util.Vector, enrollment.EACExamSchedule" %>
<%
	DBOperation dbOP  = null;
	WebInterface WI   = new WebInterface(request);
	Vector vRetResult = null;
	String strErrMsg  = null;
	String strTemp    = null;

	boolean bolBatchPrint = false;
	if(WI.fillTextValue("batch_print").equals("1"))
		bolBatchPrint = true;
	
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ENROLLMENT-REPORTS"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ENROLLMENT"),"0"));
		}
		//may be called from registrar.
	}
	if(iAccessLevel == -1)//for fatal error.
	{
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are already logged out. Please login again.");
		response.sendRedirect("../../../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../../../commfile/unauthorized_page.jsp");
		return;
	}
	try
	{
		dbOP = new DBOperation();
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
	}
String strExamName = null;
String strSubSecIndex = WI.fillTextValue("sub_sec_i");
strExamName    = (String)request.getAttribute("exam_name_");

EACExamSchedule EES = new EACExamSchedule();
if(strSubSecIndex != null)
	vRetResult = EES.getAttendance(dbOP, strSubSecIndex);

if(strExamName == null) {
	strExamName = "select exam_name from fa_pmt_schedule where pmt_sch_index = "+WI.fillTextValue("pmt_schedule");
	strExamName = dbOP.getResultOfAQuery(strExamName, 0);
}

dbOP.cleanUP();

if(vRetResult == null) {%>
	<%=EES.getErrMsg()%>
<%
return;}%>

<%
Vector vOfferingInfo = (Vector)vRetResult.remove(0);
String[] astrConvertTerm = {"SUMMER","FIRST SEMESTER","SECOND SEMESTER","THIRD SEMESTER"};
%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr>
		<td align="center" colspan="2"><font size="3">
					Schedule of <%=strExamName%> Departmental Examination <br>
							<%=astrConvertTerm[Integer.parseInt(WI.fillTextValue("semester"))]%> AY <%=WI.fillTextValue("sy_from")%> - <%=Integer.parseInt(WI.fillTextValue("sy_from")) + 1%>
	  </font>		</td>
	</tr>
	<tr>
	  <td width="71%">Control Number: <%=WI.getStrValue((String)vOfferingInfo.elementAt(5), "Not Defined")%></td>
	  <td width="29%">&nbsp;</td>
    </tr>
	<tr>
	  <td>Subject: <%=vOfferingInfo.elementAt(8)%></td>
	  <td>Date of Exam: <%=WI.formatDate((String)vOfferingInfo.elementAt(1), 6)%></td>
    </tr>
	<tr>
	  <td>Faculty: <%=WI.getStrValue((String)vOfferingInfo.elementAt(0), "Not Defined")%></td>
	  <td>Exam Room#: <%=WI.getStrValue((String)vOfferingInfo.elementAt(4), "Not Defined")%></td>
    </tr>
	<tr>
	  <td>Schedule: <%=WI.getStrValue((String)vOfferingInfo.elementAt(9), "Not Defined")%> - <%=WI.getStrValue((String)vOfferingInfo.elementAt(10), "Not Defined")%></td>
	  <td>Time of Exam: <%=vOfferingInfo.elementAt(2)%> - <%=vOfferingInfo.elementAt(3)%></td>
    </tr>
	<tr>
	  <td>&nbsp;</td>
	  <td>&nbsp;</td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr style="font-weight:bold">
		<td width="10%" class="thinborderBOTTOM" height="22">Count </td>
		<td width="19%" class="thinborderBOTTOM">Student ID </td>
		<td width="44%" class="thinborderBOTTOM">Student Name </td>
		<td width="17%" class="thinborderBOTTOM">Signature</td>
		<td width="10%" class="thinborderBOTTOM" align="center">Set</td>
	</tr>
<%int iCount = 0;
for(int i =0; i < vRetResult.size(); i += 2){%>
	<tr>
	  <td class="thinborderNONE" height="22"><%=++iCount%></td>
	  <td class="thinborderNONE"><%=(String)vRetResult.elementAt(i)%></td>
	  <td class="thinborderNONE"><%=(String)vRetResult.elementAt(i + 1)%></td>
	  <td class="thinborderNONE">__________________________</td>
	  <td class="thinborderNONE" align="center">_____</td>
    </tr>
<%}%>
</table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr>
		<td width="50%">
		Set A: <br>
		Set B: <br>
		Set C: <br>
		Set D: <br>
		Total: ____________		</td>
	    <td width="50%" valign="top">
		Proctor: <br><br><br>
		
		___________________________________<br>
		&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Signature over printed Name
		</td>
	</tr>
</table>
<%
if(dbOP!=null)
	dbOP.cleanUP();
%>

