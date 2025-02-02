<%@ page language="java" import="utility.*, lms.CirculationReport, java.util.Vector" %>
<%
	WebInterface WI = new WebInterface(request);
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	if(strSchCode == null)
		strSchCode = "";
	boolean bolIsCIT = strSchCode.startsWith("CIT");
%>


<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title></title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript">
function PrintPg() {
	document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable2').deleteRow(0);

	window.print();
}

function viewDtls(strSubArea, strCollegeCode){
	var strIsTotal = "0";
	if(strSubArea.length == 0)
		strIsTotal = "1";
		
	var strIsLC = "";
	if(document.form_.is_lc.checked)
		strIsLC = "1";
	
	var strReportType = document.form_.report_type.value;
	var strDateFrom   = "";
	var strDateTo     = "";
	var strYearOf     = "";
	var strMonthOf    = "";
	var strSYFrom     = "";
	var strSemester   = "";
	
	if(strReportType == '1'){
		strDateFrom   = document.form_.date_fr.value;
	}else if(strReportType == '2'){
		strDateFrom   = document.form_.date_fr.value;
		strDateTo     = document.form_.date_to.value;
	}else if(strReportType == '3'){
		strYearOf     = document.form_.year_of.value;
		strMonthOf    = document.form_.month_of.value;
	}else if(strReportType == '4'){
		strYearOf     = document.form_.year_of.value;
	}else if(strReportType == '5'){
		strSYFrom     = document.form_.sy_from.value;
		strSemester   = document.form_.offering_sem.value;	
	}
	
	var pgLoc = "./circ_by_collection_section_by_subject_area_view.jsp?report_type="+strReportType+"&date_fr="+strDateFrom+
		"&date_to="+strDateTo+"&year_of="+strYearOf+"&month_of="+strMonthOf+"&sy_from="+strSYFrom+"&semester="+strSemester+
		"&subject_area="+strSubArea+"&c_code="+strCollegeCode+
		"&is_total="+strIsTotal+
		"&_search=1&by_subject_area=1&is_lc="+strIsLC;
			
	var win=window.open(pgLoc,"viewDtls",'width=950,height=550,top=110,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=yes,menubar=no');
	win.focus();
	

}

</script>
<script src="../../../jscript/common.js"></script>
<script src="../../../jscript/date-picker.js"></script>
<%
	DBOperation dbOP = null;
	//WebInterface WI  = new WebInterface(request);
	String strErrMsg = null;
	String strTemp   = null;

//add security here.
	try {
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),"LIB_Circulation","circ_by_borrowers_group_by_subject_area.jsp");
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


//end of authenticaion code.
CirculationReport cReport = new CirculationReport();
Vector vRetResult = null; 
Vector vColumnDetail = null;
if(WI.fillTextValue("search").length() > 0) {
	vRetResult = cReport.circulationBorrowerGroupSubjArea(dbOP, request);
	if(vRetResult == null)
		strErrMsg = cReport.getErrMsg();
	else	
		vColumnDetail = (Vector)vRetResult.remove(0);
}

String[] astrConvertMonth = {"January","February","March","April","May","June","July","August","September","October","November","December"};
String[] astrConvertTerm  = {"Summer","1st Sem","2nd Sem","3rd Sem"};
String strReportName = null;
String strReportType = WI.fillTextValue("report_type");
if(strReportType.equals("1"))
	strReportName = " Daily Report for Date : "+WI.fillTextValue("date_fr");
else if(strReportType.equals("2"))
	strReportName = " Report for Date : "+WI.fillTextValue("date_fr") +" - "+WI.fillTextValue("date_to");
else if(strReportType.equals("3") && WI.fillTextValue("month_of").length() > 0)
	strReportName = " Monthly Report for : "+astrConvertMonth[Integer.parseInt(WI.fillTextValue("month_of"))]+", "+WI.fillTextValue("year_of");
else if(strReportType.equals("4"))
	strReportName = " Yearly report for Year : "+WI.fillTextValue("year_of");
else if(strReportType.equals("5") && WI.fillTextValue("offering_sem").length() > 0)
	strReportName = " Semestral report for : "+astrConvertTerm[Integer.parseInt(WI.fillTextValue("offering_sem"))]+", "+WI.fillTextValue("sy_from");


%>
<body topmargin="0" bottommargin="0">
<form action="./circ_by_borrowers_group_by_subject_area.jsp" method="post" name="form_" onSubmit="SubmitOnceButton(this);">
  <table width="100%" border="0" cellspacing="0" cellpadding="0" id="myADTable1">
    <tr> 
      <td height="25" colspan="3"><div align="center"><strong>:::: CIRCULATION : REPORTS : CIRCULATION BY BORROWERS GROUPS BY SUBJECT AREA PAGE ::::</strong></div></td>
    </tr>
    <tr valign="top"> 
      <td colspan="3" style="font-weight:bold; color:#FF0000; font-size:13px;"><a href="reports_main.jsp"><img src="../../../images/go_back.gif" border="0"></a>
	  &nbsp;&nbsp;<%=WI.getStrValue(strErrMsg)%>
	  </td>
    </tr>
    
    <tr> 
      <td width="6%" height="25">&nbsp;</td>
      <td width="14%">Frequency of Report</td>
      <td width="80%"><font size="1"> 
        <select name="report_type" onChange="document.form_.search.value='';document.form_.submit();">
          <option value="1">Daily</option>
<%
if(strReportType.equals("2"))
	strTemp = " selected";
else	
	strTemp = "";
%>
          <option value="2"<%=strTemp%>>Date Range</option>
<%
if(strReportType.equals("3"))
	strTemp = " selected";
else	
	strTemp = "";
%>
          <option value="3"<%=strTemp%>>Monthly</option>
<%
if(strReportType.equals("4"))
	strTemp = " selected";
else	
	strTemp = "";
%>
          <option value="4"<%=strTemp%>>Yearly</option>
<%
if(strReportType.equals("5"))
	strTemp = " selected";
else	
	strTemp = "";
%>
          <option value="5"<%=strTemp%>>Semestral</option>
        </select>
<%if(strSchCode.startsWith("CLDH") || true){
	strTemp = WI.fillTextValue("is_lc");
	if(strTemp.equals("1"))
		strTemp = "checked";
	else
		strTemp = "";
	%>
		&nbsp;&nbsp;
		<input type="checkbox" name="is_lc" value="1" <%=strTemp%> onClick="document.form_.search.value='1';document.form_.submit();"> Show LC Format
<%}%>
		
		</font></td>
    </tr>
<%if(strReportType.length() == 0 || strReportType.equals("1")){%>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td>
<%
strTemp = WI.fillTextValue("date_fr");
if(strTemp.length() == 0) 
	strTemp = WI.getTodaysDate(1);
%> <input name="date_fr" type="text"  class="textbox" onFocus="style.backgroundColor='#D3EBFF'"
	  onBlur="style.backgroundColor='white'" size="10" readonly value="<%=strTemp%>"> 
        <a href="javascript:show_calendar('form_.date_fr');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a>		</td>
    </tr>
<%}
else if(strReportType.equals("2")){%>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td>
<input name="date_fr" type="text"  class="textbox" onFocus="style.backgroundColor='#D3EBFF'"
	  onBlur="style.backgroundColor='white'" size="10" readonly value="<%=WI.fillTextValue("date_fr")%>"> 
        <a href="javascript:show_calendar('form_.date_fr');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a>
	to 
<input name="date_to" type="text"  class="textbox" onFocus="style.backgroundColor='#D3EBFF'"
	  onBlur="style.backgroundColor='white'" size="10" readonly value="<%=WI.fillTextValue("date_to")%>"> 
        <a href="javascript:show_calendar('form_.date_to');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a>	  </td>
    </tr>
<%}
else if(strReportType.equals("3")){%>    
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td>
<%
strTemp = WI.fillTextValue("year_of");
if(strTemp.length() == 0) {
	strTemp = WI.getTodaysDate();
	strTemp = strTemp.substring(0,4);
}%>
	  <input name="year_of" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  	onFocus="style.backgroundColor='#D3EBFF'" onBlur="AllowOnlyInteger('form_','year_of');style.backgroundColor='white'"
		onKeyUp="AllowOnlyInteger('form_','year_of');"> - 
		 <select name="month_of">
			<%=dbOP.loadComboMonth(WI.fillTextValue("month_of"))%>
		</select>	  </td>
    </tr>
<%}
else if(strReportType.equals("4")){%>    
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td>
<%
strTemp = WI.fillTextValue("year_of");
if(strTemp.length() == 0) {
	strTemp = WI.getTodaysDate();
	strTemp = strTemp.substring(0,4);
}%>
	  <input name="year_of" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  	onFocus="style.backgroundColor='#D3EBFF'" onBlur="AllowOnlyInteger('form_','year_of');style.backgroundColor='white'"
		onKeyUp="AllowOnlyInteger('form_','year_of');">	  </td>
    </tr>
<%}
else if(strReportType.equals("5")){%>    
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td>

<%
  strTemp = WI.fillTextValue("sy_from");
  if(strTemp.length() ==0) 
  	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%>
        <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeyUp="AllowOnlyInteger('form_','sy_from');">
	  <select name="offering_sem">
          <option value="0">Summer</option>
          <%
strTemp = WI.fillTextValue("offering_sem");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sem");
if(strTemp.equals("1")){%>
          <option value="1" selected>1st Sem</option>
<%}else{%>
          <option value="1">1st Sem</option>
<%}if(strTemp.equals("2")){%>
          <option value="2" selected>2nd Sem</option>
<%}else{%>
          <option value="2">2nd Sem</option>
<%}if(strTemp.equals("3")){%>
          <option value="3" selected>3rd Sem</option>
<%}else {%>
          <option value="3">3rd Sem</option>
<%}%>
        </select>
	  </td>
    </tr>
<%}//end of showing report type.. 
%>
    <tr>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td><input type="submit" name="1" value="&nbsp; Show Report &nbsp;" style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="document.form_.search.value='1'"></td>
    </tr>
</table>
<%if(vRetResult != null && vRetResult.size() > 0) {
Vector vRowDetail = new Vector();
if(WI.fillTextValue("is_lc").length() == 0) {
	vRowDetail.addElement("000 - 099");vRowDetail.addElement("0");
	vRowDetail.addElement("100 - 199");vRowDetail.addElement("1");
	vRowDetail.addElement("200 - 299");vRowDetail.addElement("2");
	vRowDetail.addElement("300 - 399");vRowDetail.addElement("3");
	vRowDetail.addElement("400 - 499");vRowDetail.addElement("4");
	vRowDetail.addElement("500 - 599");vRowDetail.addElement("5");
	vRowDetail.addElement("600 - 699");vRowDetail.addElement("6");
	vRowDetail.addElement("700 - 799");vRowDetail.addElement("7");
	vRowDetail.addElement("800 - 899");vRowDetail.addElement("8");
	vRowDetail.addElement("900 - 999");vRowDetail.addElement("9");
}
else {//get LC 
	strTemp = "select LC_GEN_CODE, LC_INT from LMS_DDC_GEN_CATG where is_valid = 1 and lc_gen_code is not null order by LC_GEN_CODE";
	java.sql.ResultSet rs = dbOP.executeQuery(strTemp);
	while(rs.next()) {
		vRowDetail.addElement(rs.getString(1));// LC Code - A
		vRowDetail.addElement(rs.getString(2));//LC INT - 1
	}
	rs.close();
}
int iCountPerCell = 0;//every cell
int iRowTotal     = 0; 
int iGT           = 0;
int iColTotal[]   = null;  
if(vColumnDetail != null)
	iColTotal = new int[vColumnDetail.size()/2];
%>
<table width="100%" border="0" cellspacing="0" cellpadding="0" id="myADTable2">
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td><div align="right"><a href="javascript:PrintPg();"><img src="../../../images/print.gif" border="0"></a><font size="1">click 
          to print report</font></div></td>
    </tr>
    <tr> 
      <td height="25" colspan="3" align="center">
      <strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong><br>
        <font size="1"><%=SchoolInformation.getAddressLine1(dbOP,false,false)%></font>
	  <br>
	  </td>
    </tr>
    <tr> 
      <td height="25" colspan="3" align="center" style="font-weight:bold">Circulation By Borrowers Group by Subject Area : <%=strReportName%></td>
    </tr>
  </table>

<table width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
		<tr style="font-weight:bold"> 
		  <td width="10%" height="22" class="thinborder" align="center"><font size="1">SUBJECT AREA /BORROWERS GROUP</font></td>
		  <%
		  for(int i =0; i < vColumnDetail.size(); i += 2){		  
		  %>		  
		  <td class="thinborder" width="4" align="center"><font size="1"><%=(String)vColumnDetail.elementAt(i)%></font></td>
		  <%}%>
		  <td width="6%" class="thinborder" align="center"><font size="1">TOTAL</font></td>
		</tr
		><%

	 String strCollegeCode = null;				
	 for(int i = 0; i < vRowDetail.size(); i += 2) {
		strTemp = (String)vRowDetail.elementAt(i + 1);%>
		<tr> 
		  <td height="25" class="thinborder" align="center"><strong><font size="1"> 
			  <%=vRowDetail.elementAt(i)%></font></strong></td>
		  <%
		  for(int p =0; p < vColumnDetail.size(); p += 2){
			  strErrMsg =(String)vColumnDetail.elementAt(p);
			  
			  iCountPerCell = 0;
			  for(int q = 0 ; q < vRetResult.size(); q += 3) {
				if(strTemp.equals((String)vRetResult.elementAt(q)) && strErrMsg.equals((String)vRetResult.elementAt(q + 1)) ) {
					strCollegeCode = (String)vRetResult.elementAt(q + 1);
					vRetResult.remove(q);vRetResult.remove(q);
					iCountPerCell = Integer.parseInt((String)vRetResult.remove(q));					
					break;
				}
			  }
			  iRowTotal += iCountPerCell;
			  iGT += iCountPerCell;
			  iColTotal[p/2] += iCountPerCell;
			  %>
			  <td class="thinborder" align="center">
			  	<%if(iCountPerCell > 0){%>					
						<a href="javascript:viewDtls('<%=strTemp%>','<%=strCollegeCode%>');"><font size="1"><%=iCountPerCell%></font></a>
				<%}else{%>-<%}%></td>
		  <%}//show count here.%>
		  <td class="thinborder" align="center"> 
		  <%if(iRowTotal > 0){%> 
		  	<font size="1"><a href="javascript:viewDtls('<%=strTemp%>','Grand Total');"><%=iRowTotal%></a></font> 
		<%}else{%>-<%}iRowTotal = 0;%> </td>
		</tr>
		<%}%>
		
		<tr> 
		  <td height="25" class="thinborder" align="center"><strong><font size="1">TOTAL</font></strong></td>
		  <%	  
		  for(int i =0; i < vColumnDetail.size(); i += 2){%>
		  <td class="thinborder" align="center"><strong><font size="1">
		  <%if(iColTotal[i/2] > 0){%>
		  	<a href="javascript:viewDtls('','<%=vColumnDetail.elementAt(i)%>');"><%=iColTotal[i/2]%></a>
			<%}else{%><%=iColTotal[i/2]%><%}%>
		 </font></strong></td>
		  <%}//show totalcount here.%>
		  <td class="thinborder" align="center"> 
		  	<strong><%if(iGT > 0){%> <font size="1"><a href="javascript:viewDtls('','Grand Total');"><%=iGT%></a></font>  <%}else{%> - <%}%></strong>
		  </td>
		</tr>
  </table>  

<%}//end of vRetResult.%>
<input type="hidden" name="search">	
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>