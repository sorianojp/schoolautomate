<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title></title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript" src="../../../jscript/date-picker.js"></script>
<script language="javascript">
function ReloadPage() {
	document.form_.view_report.value = "";
	document.form_.submit();
}
function ViewReport() {
	document.form_.view_report.value = "1";
	document.form_.submit();
}
function PrintPg() {
	document.bgColor = "#FFFFFF";
   	document.getElementById('myADTable1').deleteRow(0);
   	document.getElementById('myADTable1').deleteRow(0);
   	document.getElementById('myADTable1').deleteRow(0);
   	document.getElementById('myADTable1').deleteRow(0);
   	document.getElementById('myADTable1').deleteRow(0);
   	document.getElementById('myADTable1').deleteRow(0);
   	document.getElementById('myADTable1').deleteRow(0);
   	document.getElementById('myADTable1').deleteRow(0);

   	document.getElementById('myADTable2').deleteRow(0);

   	alert("Click OK to print this page");
	window.print();//called to remove rows, make bk white and call print.
}
var imgWnd;
function ShowProcessing()
{
	imgWnd=
	window.open("../../../commfile/processing.htm","PrintWindow",'width=600,height=300,top=220,left=200,toolbar=no,location=no,directories=no,status=no,menubar=no');
	imgWnd.focus();
}
function CloseProcessing()
{
	if (imgWnd && imgWnd.open && !imgWnd.closed) imgWnd.close();
}
</script>
<body bgcolor="#DEC9CC">
<%@ page language="java" import="utility.*,lms.CatalogReport,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp   = null;
	WebInterface WI  = new WebInterface(request);

//add security here.
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
//authenticate this user.
	CatalogReport CR  = new CatalogReport();
	Vector vRetResult = null;
	Vector vMatType   = null;
	
	if(WI.fillTextValue("view_report").equals("1")){
		vRetResult = CR.genProcessedByMatType(dbOP, request);
		if(vRetResult == null) 
			strErrMsg = CR.getErrMsg();
		else	
			vMatType  = (Vector)vRetResult.remove(0);
	}
	
String strReportName = "Report Type : ";
if(WI.fillTextValue("report_type").equals("0") && WI.fillTextValue("date_fr").length() > 0 ) {
	if(WI.fillTextValue("date_to").length() == 0) 
		strReportName += " Daily - for date "+WI.fillTextValue("date_fr");
	else	
		strReportName += " Weekly - for date range "+WI.fillTextValue("date_fr")+" to "+
			WI.fillTextValue("date_to");
}	
else if(WI.fillTextValue("report_type").equals("1") && WI.fillTextValue("month_fr").length() > 0){
	String[] astrConvertToMonth = {"January", "February","March","April","May","June","July","August",
									"September","October","November","December"};
	if(WI.fillTextValue("month_to").equals("-1")) 
		strReportName += " Monthly - for month of "+astrConvertToMonth[Integer.parseInt(WI.fillTextValue("month_fr"))];
	else	
		strReportName += " Monthly - for month range of "+astrConvertToMonth[Integer.parseInt(WI.fillTextValue("month_fr"))]+" to "+
			astrConvertToMonth[Integer.parseInt(WI.fillTextValue("month_to"))];
}
else if(WI.fillTextValue("year_fr").length() > 0){
	if(WI.fillTextValue("year_to").equals("-1")) 
		strReportName += " Yearly - for year of "+WI.fillTextValue("year_fr");
	else	
		strReportName += " Yearly - for year range of "+WI.fillTextValue("year_fr")+" to "+
			WI.fillTextValue("year_to");
}
%>
<form action="./pro_col_by_material_type_dbtc.jsp" method="post" name="form_">
<input type="hidden" name="view_report" value="<%=WI.fillTextValue("view_report")%>">  
  <table width="100%" border="0" cellspacing="0" cellpadding="0" id="myADTable1">
    <tr bgcolor="#A8A8D5"> 
      <td height="25" colspan="3"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          CATALOGING : REPORTS - PROCESSED COLLECTION BY MATERIAL TYPE ::::</strong></font></div></td>
    </tr>
    <tr valign="top"> 
      <td height="42" colspan="3"><a href="main_page.jsp" target="_self"><img src="../../images/go_back.gif" border="0" ></a>
	  &nbsp;&nbsp;
	  <font size="3" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
    
    <tr> 
      <td width="6%" height="25">&nbsp;</td>
      <td width="15%">Freq. of Report</td>
      <td width="79%"><font size="1"> 
        <select name="report_type" onChange="ReloadPage();">
          <option value="0">Daily or Weekly</option>
<%
strTemp = WI.fillTextValue("report_type");
if(strTemp.equals("1"))
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>          <option value="1"<%=strErrMsg%>>Monthly</option>
<%
if(strTemp.equals("2"))
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>          <option value="2"<%=strErrMsg%>>Annual</option>
        </select>
        </font></td>
    </tr>

<%if(strTemp.length() == 0 || strTemp.equals("0")) {//Daily or weekly. report%>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td><%
strTemp = WI.fillTextValue("date_fr");
if(strTemp.length() == 0) 
	strTemp = WI.getTodaysDate(1);
%>
        From <input name="date_fr" type="text"  class="textbox" onFocus="style.backgroundColor='#D3EBFF'"
	  onBlur="style.backgroundColor='white'" size="10" readonly value="<%=strTemp%>">
        <a href="javascript:show_calendar('form_.date_fr');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a> to
        <input name="date_to" type="text"  class="textbox" onFocus="style.backgroundColor='#D3EBFF'"
	  onBlur="style.backgroundColor='white'" size="10" readonly value="<%=WI.fillTextValue("date_to")%>">
        <a href="javascript:show_calendar('form_.date_to');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a> <br>
      <strong><font size="1">(For daily report, enter From date value only)</font></strong></td>
    </tr>
<%}else if(strTemp.equals("1")){//monthly.. or month range.%>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td>From 
        <select name="month_fr">
			<%=dbOP.loadComboMonth(WI.fillTextValue("month_fr"))%>
		</select> 
        to 
<%
strTemp = WI.fillTextValue("month_to");		
if(strTemp.length() == 0) 
	strTemp = "-1";
%>
        <select name="month_to">
			<option value="-1"></option>
			<%=dbOP.loadComboMonth(strTemp)%>
		</select>		</td>
    </tr>
<%}else{//yearly or year range...%>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td>From 
		<select name="year_fr">
			<%=dbOP.loadComboYear(WI.fillTextValue("year_fr"),5,1)%>
		</select>	 to
<%
strTemp = WI.fillTextValue("year_to");		
if(strTemp.length() == 0) 
	strTemp = "-1";
%>
		<select name="year_to">
          <option value="-1"></option>
          <%=dbOP.loadComboYear(strTemp,5,1)%>
        </select></td>
    </tr>
<%}//end of report type.%>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="2">Material Type</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="2"><select name="MATERIAL_TYPE_INDEX" 
	  style="font-family:Verdana, Arial, Helvetica, sans-serif;font-size: 10;">
        <option value=""> --------- All Material Type --------- </option>
		<%=dbOP.loadCombo("MATERIAL_TYPE_INDEX","MATERIAL_TYPE"," from LMS_MAT_TYPE order by  MATERIAL_TYPE_INDEX asc",
		  	WI.fillTextValue("MATERIAL_TYPE_INDEX"), false)%>
      </select></td>
    </tr>
    <tr>
      <td height="21">&nbsp;</td>
      <td colspan="2"><strong>SORT&nbsp;&nbsp;</strong>
        <%
strTemp = WI.fillTextValue("sort_by");
if(strTemp.equals("AUTHOR_NAME"))
	strErrMsg = " checked";
else 
	strErrMsg = "";
%>
        <input type="radio" name="sort_by" value="AUTHOR_NAME"<%=strErrMsg%>>
        Author &nbsp;&nbsp;
        <%
if(strTemp.equals("BOOK_TITLE"))
	strErrMsg = " checked";
else 
	strErrMsg = "";
%>
        <input type="radio" name="sort_by" value="BOOK_TITLE"<%=strErrMsg%>>
        Title &nbsp;&nbsp;
        <%
if(strTemp.length() == 0 || strTemp.equals("CALL_NUMBER"))
	strErrMsg = " checked";
else 
	strErrMsg = "";
%>
        <input type="radio" name="sort_by" value="CALL_NUMBER"<%=strErrMsg%>>
      Call Number</td>
    </tr>
    <tr> 
      <td height="21">&nbsp;</td>
      <td>&nbsp;</td>
      <td><a href="javascript:ViewReport();"><img src="../../images/form_proceed.gif" border="0"></a></td>
    </tr>
  </table>
<%
if(vRetResult != null && vRetResult.size() > 0) {%>
<script language="javascript">
this.ShowProcessing();
</script>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" id="myADTable2">
    <tr> 
      <td height="42">&nbsp;</td>
      <td>&nbsp;</td>
      <td><div align="right"><a href="javascript:PrintPg();"><img src="../../images/print.gif" border="0"></a>
	  	<font size="1">click to print report</font></div></td>
    </tr>
    <tr> 
      <td height="42" colspan="3" align="center">
	  <strong><em>:::: CATALOGING : REPORTS - PROCESSED COLLECTION BY MATERIAL TYPE ::::</em></strong><br>
          <font size="2"><strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong><br>
          <font size="1"><%=SchoolInformation.getAddressLine1(dbOP,false,false)%> <br>
      <%=strReportName%> </font></font>	  </td>
    </tr>
    <tr>
      <td height="10" colspan="3" align="right">
	  <font size="1">Date and time printed : <%=WI.getTodaysDateTime()%></font>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
    </tr>
  </table>
<%String strMatTypeIndex = null;
for(int i = 0; i < vMatType.size(); i +=3 ){
strMatTypeIndex = (String)vMatType.elementAt(i);%>  
  <table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
    <tr> 
      <td height="25" colspan="8" bgcolor="#DDDDEE" class="thinborder"><font color="#FF0000"><strong>
	  Total Count : <%=CommonUtil.formatFloat((String)vMatType.elementAt(i + 2),false)%>
	  &nbsp;&nbsp;MATERIAL TYPE: <%=(String)vMatType.elementAt(i + 1)%> </strong></font></td>
    </tr>
    <tr> 
      <td width="8%" height="25" class="thinborder"><div align="center"><strong><font size="1">CALL NO.</font></strong></div></td>	  
      <td width="10%" class="thinborder"><div align="center"><strong><font size="1">AUTHOR</font></strong></div></td>
      <td width="30%" class="thinborder"><div align="center"><strong><font size="1">TITLE</font></strong></div></td>
      <td width="13%" class="thinborder"><div align="center"><strong><font size="1">PLACE OF PUBLICATION</font></strong></div></td>
      <td width="10%" class="thinborder"><div align="center"><strong><font size="1">PUBLISHER</font></strong></div></td>
      <td width="9%" class="thinborder"><div align="center"><strong><font size="1">COPYRIGHT DATE</font></strong></div></td>
	  <td width="10%" class="thinborder"><div align="center"><strong><font size="1">ACCESSION NO</font></strong></div></td>
	  <td width="10%" class="thinborder"><div align="center"><strong><font size="1">LIB LOCATION</font></strong></div></td>
    </tr>
<%
for(int p = 0; p < vRetResult.size();){
	if( !strMatTypeIndex.equals((String)vRetResult.elementAt(0)))
		break;
	vRetResult.removeElementAt(0);
%>
    <tr> 
      <td height="25" class="thinborder">&nbsp;<%=(String)vRetResult.remove(0)%></td>
      <td class="thinborder">&nbsp;<%=(String)vRetResult.remove(0)%></td>
      <td class="thinborder">&nbsp;<%=(String)vRetResult.remove(0)%><%=WI.getStrValue((String)vRetResult.remove(0),"::","","")%></td>
      <td class="thinborder">&nbsp;<%=(String)vRetResult.remove(0)%></td>
      <td class="thinborder">&nbsp;<%=(String)vRetResult.remove(0)%></td>
      <td class="thinborder">&nbsp;<%=(String)vRetResult.remove(0)%></td>
	  <td class="thinborder">&nbsp;<%=(String)vRetResult.remove(0)%></td>
	  <td class="thinborder">&nbsp;<%=(String)vRetResult.remove(0)%></td>
    </tr>
<%
	vRetResult.remove(0);vRetResult.remove(0);vRetResult.remove(0);vRetResult.remove(0);
	vRetResult.remove(0);vRetResult.remove(0);
	vRetResult.remove(0);vRetResult.remove(0);vRetResult.remove(0);vRetResult.remove(0);
	vRetResult.remove(0);vRetResult.remove(0);vRetResult.remove(0);vRetResult.remove(0);

}//end of inner for loop.%>
  </table> 
<%}//for(int i = 0; i < vMatType.size(); i += )
}%>

<script language="javascript">
	this.CloseProcessing();
</script>
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
