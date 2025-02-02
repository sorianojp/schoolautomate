<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Subject Schedule Reference Page</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript">
function copyValueToParent()
{
	//var maxDisplay = eval(document.block_sec.max_disp.value);
	//alert(document.block_sec.section.value);
	
	//for(var i=0; i<maxDisplay; ++i)
		eval('window.opener.document.'+document.block_sec.form_name.value+'.block_sec.value=\"'+document.block_sec.section.value+'\"');
		eval('window.opener.document.'+document.block_sec.form_name.value+'.selAll.checked=true');
	eval('window.opener.document.'+document.block_sec.form_name.value+'.submit()');
	window.close();
}
function SelSection(strSection)
{
	document.block_sec.section.value = strSection;
}
function ViewSectionDetail(strSection)
{
	var loadPg = "./block_section_view.jsp?ci="+document.block_sec.ci.value+"&mi="+document.block_sec.mi.value+"&sec="+
	escape(strSection)+"&syf="+document.block_sec.syf.value+"&syt="+document.block_sec.syt.value+"&sy_from="+
	document.block_sec.sy_from.value+"&sy_to="+document.block_sec.sy_to.value+"&semester="+document.block_sec.semester.value+
	"&year_level="+document.block_sec.year_level.value+"&offering_sem="+document.block_sec.offering_sem.value;
	//var win=window.open(loadPg,"myfile",'dependent=yes,width=900,height=350,screenX=200,screenY=300,scrollbars=yes,,toolbar=yes,location=yes,directories=yes,status=no,menubar=yes');
	var win2=window.open(loadPg,"myfile2",'dependent=no,width=800,height=350,top=100,left=100,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win2.focus();
}

</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,enrollment.Advising,java.util.Vector " %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String strTemp = null;


//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Enrollment-advising-block section","block_section.jsp");
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

Vector vForcedBlock = null;
String strIsBlockFoced = "0";

Advising advising = new Advising();
Vector vBlockSecList = advising.getBlockSecList(dbOP,request.getParameter("ci"),request.getParameter("mi"),
						request.getParameter("sy_from"),request.getParameter("sy_to"),request.getParameter("offering_sem"),
						request.getParameter("syf"),
						request.getParameter("syt"),request.getParameter("year_level"),request.getParameter("offering_sem"));
if(vBlockSecList == null)
	strErrMsg = advising.getErrMsg();
else {
	//I have to get the list of block section those are forced.. if forced, i have to show only those blocks.
	vForcedBlock = new enrollment.SubjectSection().getForcedBlockSectionList(dbOP, request, request.getParameter("sy_from"), request.getParameter("offering_sem"));

	//remove if there are forced block.
	if(vForcedBlock != null && vForcedBlock.size() > 0) {
		strIsBlockFoced = "1";
		for(int i=1; i< vBlockSecList.size(); ++i){
			if(vForcedBlock.indexOf(vBlockSecList.elementAt(i)) == -1) {
				vBlockSecList.remove(i);
				--i;
				continue;
			}	
		}
		if(vBlockSecList.size() == 1) {
			vBlockSecList = null;
			strErrMsg = "Block Section not found.";
		}
		
	}

}


dbOP.cleanUP();
String[] astrConvertSem = {"Summer","1st Sem","2nd Sem","3rd Sem","4th Sem"};
%>
<form name="block_sec">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="2" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>::::
          BLOCK SECTION PAGE ::::</strong></font></div></td>
    </tr>
    <tr >
      <td width="2%" height="25">&nbsp;</td>
      <td width="98%" height="25">&nbsp;</td>
    </tr>
<%
if(strErrMsg != null)
{%>	<tr >
      <td height="25">&nbsp;</td>
      <td><%=strErrMsg%></td>

    </tr>
<%return;}%>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr >
      <td  width="2%" height="25">&nbsp;</td>
      <td height="25" colspan="3">Course/Major: <strong><%=request.getParameter("cn")%>
        <%if(WI.fillTextValue("mn").length() > 0){%>
        /<%=request.getParameter("mn")%>
        <%}%>
        </strong></td>
    </tr>
    <tr >
      <td height="25">&nbsp;</td>
      <td width="45%" height="25">Curriculum Year:<strong><%=request.getParameter("syf")%>
        - <%=request.getParameter("syt")%></strong></td>
      <td colspan="2">&nbsp;</td>
    </tr>
    <tr >
      <td height="25">&nbsp;</td>
      <td height="25">Enrolling Year: <strong><%=request.getParameter("sy_from")%>
        - <%=request.getParameter("sy_to")%></strong></td>
      <td colspan="2">Year/Term :<strong><%=request.getParameter("year_level")%>/
        <%=astrConvertSem[Integer.parseInt(request.getParameter("offering_sem"))]%></strong></td>
    </tr>
    <tr >
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td width="16%">&nbsp;</td>
      <td width="37%">&nbsp;</td>
    </tr>
  </table>


  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#B9B292">
      <td height="25" colspan="9"><div align="center">SECTIONS OFFERED/OPEN FOR
          THIS COURSE </div></td>
    </tr>
    <tr >
      <td width="1%" height="25">&nbsp;</td>
      <td colspan="2" height="25">&nbsp;</td>
      <td width="16%" height="25" colspan="6">
	  <a href="javascript:copyValueToParent();"><img src="../../../images/form_proceed.gif" width="81" height="21" border="0"></a>
	  </td>
    </tr>
  </table>
  <table width="100%" border="1" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr >
      <td width="20%" height="25"><div align="center"><strong><font size="1">SECTION</font></strong></div></td>
      <td width="23%"><div align="center"><strong><font size="1"><strong>SELECT</strong></font></strong></div></td>
      <td width="23%"><div align="center"><font size="1">Click to see complete
          schedule for this section</font></div></td>
    </tr>
    <%
for(int i=1; i< vBlockSecList.size(); ++i){
 %>
    <tr >
      <td height="25" align="center"><%=(String)vBlockSecList.elementAt(i)%></td>
      <td align="center"><input type="radio" name="radiobutton" value="radiobutton" onClick='SelSection("<%=(String)vBlockSecList.elementAt(i)%>");'></td>
      <td><div align="center"><a href='javascript:ViewSectionDetail("<%=(String)vBlockSecList.elementAt(i)%>");'>
	  <img src="../../../images/view.gif" width="40" height="31" border="0"></a></div></td>
    </tr>
    <%}%>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <td width="12%"></tr>
    <tr bgcolor="#FFFFFF">
      <td width="84%">&nbsp;</td>
      <td width="16%" height="25">
	  <a href="javascript:copyValueToParent();"><img src="../../../images/form_proceed.gif" width="81" height="21" border="0"></a>
	  </td>
    </tr>
    <tr bgcolor="#B8CDD1">
      <td height="25" colspan="8" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
  <input type="hidden" name="section">
  <input type="hidden" name="form_name" value="<%=request.getParameter("form_name")%>">
  <input type="hidden" name="max_disp" value="<%=request.getParameter("max_disp")%>">

  <!-- needed for viewing section schedule detail -->
  <input type="hidden" name="ci" value="<%=WI.fillTextValue("ci")%>">
  <input type="hidden" name="mi" value="<%=WI.fillTextValue("mi")%>">
  <input type="hidden" name="syf" value="<%=WI.fillTextValue("syf")%>">
  <input type="hidden" name="syt" value="<%=WI.fillTextValue("syt")%>">
  <input type="hidden" name="sy_from" value="<%=WI.fillTextValue("sy_from")%>">
  <input type="hidden" name="sy_to" value="<%=WI.fillTextValue("sy_to")%>">
  <input type="hidden" name="year_level" value="<%=WI.fillTextValue("year_level")%>">
  <input type="hidden" name="semester" value="<%=WI.fillTextValue("semester")%>">
  <input type="hidden" name="offering_sem" value="<%=WI.fillTextValue("offering_sem")%>">
  
  <!-- if is_forced_block = 1, user can't anymore alter any select button --> 
  <input type="hidden" name="is_forced_block" value="<%=strIsBlockFoced%>">

</form>
</body>
</html>
