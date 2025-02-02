<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script src="../../../jscript/common.js"></script>
<script src="../../../jscript/date-picker.js"></script>
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
function SetBookLocName() {
	if(!document.form_.book_location)
		return;
	var selIndex = document.form_.book_location.selectedIndex;
	if(selIndex == 0) 
		document.form_.book_loc_name.value = "ALL";
	else	
		document.form_.book_loc_name.value = document.form_.book_location[selIndex].text;
}

function viewDtls(strSubArea, strCollegeCode){
	//this strSubArea is the month.

	var strIsTotal = "0";
	var strReportType = "3"
	if(strSubArea.length == 0){
		strIsTotal = "1";
		strReportType = "4"
	}
	
	var strYearOf     = document.form_.year_of.value;
	var strMonthOf    = strSubArea;
	
	
	var pgLoc = "./circ_by_collection_section_by_subject_area_view.jsp?report_type="+strReportType+
		"&year_of="+strYearOf+"&month_of="+strMonthOf+
		"&book_location="+document.form_.book_location.value+
		"&c_code="+strCollegeCode+
		"&is_total="+strIsTotal+
		"&_search=1&group_yearly=1";
			
	var win=window.open(pgLoc,"viewDtls",'width=950,height=550,top=110,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=yes,menubar=no');
	win.focus();
	

}


</script>
<%@ page language="java" import="utility.*,lms.CirculationReport,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI  = new WebInterface(request);
	String strErrMsg = null;
	String strTemp   = null;

//add security here.
	try {
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),"LIB_Circulation","circ_by_borrowers_group_yearly.jsp");
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
Vector vRetResult = null; Vector vColumnDetail = null; Vector vRowDetail = null;
if(WI.fillTextValue("search").length() > 0) {
	vRetResult = cReport.circulationSummaryByBorrowerGroupYearly(dbOP, request);
	if(vRetResult == null)
		strErrMsg = cReport.getErrMsg();
	else {
		vColumnDetail = (Vector)vRetResult.remove(0);
		vRowDetail    = (Vector)vRetResult.remove(0);
	}
}

String[] astrConvertMonth = {"January","February","March","April","May","June","July","August","September","October","November","December"};
String[] astrConvertTerm  = {"Summer","1st Sem","2nd Sem","3rd Sem"};
String strReportName = " For Year : "+WI.fillTextValue("year_of");
%>
<body topmargin="0" bottommargin="0">
<form action="./circ_by_borrowers_group_yearly.jsp" method="post" name="form_" onSubmit="SetBookLocName();SubmitOnceButton(this);">
  <table width="100%" border="0" cellspacing="0" cellpadding="0" id="myADTable1">
    <tr> 
      <td height="25" colspan="3"><div align="center"><strong>:::: CIRCULATION : REPORTS : CIRCULATION SUMMARY BY BORROWERS GROUPS - YEARLY ::::</strong></div></td>
    </tr>
    <tr valign="top"> 
      <td colspan="3" style="font-weight:bold; color:#FF0000; font-size:13px;"><a href="reports_main.jsp"><img src="../../../images/go_back.gif" border="0"></a>
	  &nbsp;&nbsp;<%=WI.getStrValue(strErrMsg)%>	  </td>
    </tr>
    <tr> 
      <td width="6%" height="25">&nbsp;</td>
      <td width="14%">For Year : </td>
      <td width="80%">
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
    <tr>
      <td height="25">&nbsp;</td>
      <td>Book Collection Loc. </td>
      <td>
	  <select name="book_location" style="font-family:Verdana, Arial, Helvetica, sans-serif;font-size: 10;">
	  	<option value=""></option>
          <%=dbOP.loadCombo("BOOK_LOC_INDEX","LOCATION"," from LMS_BOOK_LOC order by LOCATION asc",WI.fillTextValue("book_location"), false)%> 
	  </select>
	  </td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td><input type="submit" name="1" value="&nbsp; Show Report &nbsp;" style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="document.form_.search.value='1'"></td>
    </tr>
</table>
<%if(vRetResult != null && vRetResult.size() > 0) {
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
      <td height="25" colspan="3" align="center" style="font-weight:bold">Circulation Summary By Borrowers Group : <%=strReportName%></td>
    </tr>
    <tr>
      <td height="25" colspan="3" style="font-weight:bold">Book Collection Location : <%=WI.fillTextValue("book_loc_name")%></td>
    </tr>
  </table>

<table width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
		<tr style="font-weight:bold"> 
		  <td width="10%" height="22" class="thinborder" align="center"><font size="1">Month</font></td>
		  <%
		  for(int i =0; i < vColumnDetail.size(); i += 2){%>
		  <td class="thinborder" width="4" align="center"><font size="1"><%=(String)vColumnDetail.elementAt(i)%></font></td>
		  <%}%>
		  <td width="6%" class="thinborder" align="center"><font size="1">TOTAL</font></td>
		</tr>
		<%
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
				if(strTemp.equals(vRetResult.elementAt(q)) && strErrMsg.equals(vRetResult.elementAt(q + 1)) ) {
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
			  	<a href="javascript:viewDtls('<%=strTemp%>','<%=strCollegeCode%>');">
					<font size="1"><%=iCountPerCell%></font></a> 
			<%}else{%>
				- <%}%></td>
		  <%}//show count here.%>
		  <td class="thinborder" align="center"> 
		  	<%if(iRowTotal > 0){%> 
				<font size="1"><a href="javascript:viewDtls('<%=strTemp%>','Grand Total');"><%=iRowTotal%></a></font> <%}else{%>
			- 
			<%}iRowTotal = 0;%> </td>
		</tr>
		<%}%>
		<tr> 
		  <td height="25" class="thinborder" align="center"><strong><font size="1">TOTAL</font></strong></td>
		  <%
		  for(int i =0; i < vColumnDetail.size(); i += 2){
		  	strErrMsg =(String)vColumnDetail.elementAt(i);
		  %>
		  <td class="thinborder" align="center"><strong><font size="1">
		  	<%if(iColTotal[i/2] > 0){%>
		  <a href="javascript:viewDtls('','<%=strErrMsg%>');"><%=iColTotal[i/2]%></a>
		  <%}else{%><%=iColTotal[i/2]%><%}%>
		  </font></strong></td>
		  <%}//show totalcount here.%>
		  <td class="thinborder" align="center"> <strong> 
			<%if(iGT > 0){%> <font size="1"><a href="javascript:viewDtls('','Grand Total');"><%=iGT%></a></font>  <%}else{%> - <%}%>
			</strong></td>
		</tr>
  </table>  

<%}//end of vRetResult.%>
<input type="hidden" name="search">	
<input type="hidden" name="book_loc_name">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>