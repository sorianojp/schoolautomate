<%
String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null) 
	strSchCode = "";//strSchCode = "UC";

%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../jscript/td.js"></script>
<script language="JavaScript">
var imgWnd;
function PrintPg() {
	document.getElementById('myADTable1').deleteRow(0);
	
	var objT = document.getElementById('myADTable2');
	var oRows = objT.getElementsByTagName('tr');
	var iRowCount = oRows.length;
	for(i = 0; i < iRowCount; ++i)
		objT.deleteRow(0);
	
	window.print();
}

	function CallOnLoad() {
		document.all.processing.style.visibility='hidden';
		document.bgColor = "#FFFFFF";
	}

</script>
<body bgcolor="#dddddd" onLoad="CallOnLoad();">
<%@ page language="java" import="utility.*,enrollment.FAStudentLedgerExtn,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strTemp = null;
	int iSubTotal   = 0; // sub total of a course - major.

	String strErrMsg = null;
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments-REPORTS","list_stud_outstanding_refund_cumulative_ledger.jsp");
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
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Fee Assessment & Payments","Reports",request.getRemoteAddr(),
														"list_stud_outstanding_refund_cumulative_ledger.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.
Vector vRetResult  = null;
Vector vDateFrStudList = null;//holds student list having os balance as of date fr 
Vector vDateToStudList = null;//holds student list having os balance as of date to
Vector vTransDetail    = null;//holds payment/refund-debit credit/

FAStudentLedgerExtn studLedg = new FAStudentLedgerExtn();
if(WI.fillTextValue("date_fr").length() > 0 && WI.fillTextValue("date_to").length() > 0 && WI.fillTextValue("donot_show").length() == 0) {
	vRetResult = studLedg.viewCumulativeLedgerUC(dbOP, request);
	if(vRetResult == null)
		strErrMsg = studLedg.getErrMsg();
	else {
		vDateFrStudList = (Vector)vRetResult.remove(0);
		vDateToStudList = (Vector)vRetResult.remove(0);
		vTransDetail    = (Vector)vRetResult.remove(0);
	}
}
//System.out.println(vTransDetail);	

String[] astrSortByName    = {"ID #","Lastname","Firstname","Gender","Year Level"};
String[] astrSortByVal     = {"id_number","lname","fname","gender","stud_curriculum_hist.year_level"};
String[] astrConvertTerm   = {"Summer","1st Term","2nd Term","3rd Term"};

boolean bolIsBasic = false;
if(WI.fillTextValue("is_basic").length() > 0) 
	bolIsBasic = true;


boolean bolRemoveNoBalance = false;
if(WI.fillTextValue("show_with_trans").length() > 0) 
	bolRemoveNoBalance = true;
%>
<!-- Printing information. -->
<div id="processing" style="position:absolute; top:0px; left:0px; width:250px; height:50px;  visibility:visible">
<table cellpadding=0 cellspacing=0 border=0 Width=100% Height=100% align=Center class="thinborderALL">
      <tr>
            <td align="center" class="v10blancong" bgcolor="#FFCC66">
			<p style="font-size:12px; font-weight:bold; font-family:Verdana, Arial, Helvetica, sans-serif"> Processing Request. Please wait...
			<br> <font color='red'>Loading Page <label id="page_progress"></label></font></p>

			<!--<img src="../../../Ajax/ajax-loader2.gif">--></td>
      </tr>
</table>
</div>
<form action="./list_stud_outstanding_refund_cumulative_ledger.jsp" method="post" name="form_" onSubmit="SubmitOnceButton(this);">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" id="myADTable1">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25" colspan="4" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>:::: 
          LIST OF STUDENTS WITH OUTSTANDING BALANCE/REFUND PAGE ::::</strong></font></div></td>
    </tr>
  </table>

  <table  width="100%" border="0" cellspacing="0" cellpadding="0" id="myADTable2">
    <tr> 
      <td width="1%" height="25"></td>
      <td colspan="4" style="font-size:14px; color:#FF0000; font-weight:bold"><%=WI.getStrValue(strErrMsg)%></td>
    </tr>
<%if(!strSchCode.startsWith("FATIMA")){
	strTemp = WI.fillTextValue("is_basic");
	if(strTemp.length() > 0) 
		strTemp = " checked";
	%>
    <tr>
      <td height="25"></td>
      <td colspan="4" style="font-size:11px; font-weight:bold; color:#0000FF">
			  <input type="checkbox" name="is_basic" value="1"<%=strTemp%> onClick="document.form_.donot_show.value='1';document.form_.submit();"> Process Report for Grade School 
		  &nbsp;&nbsp;</td>
    </tr>
<%}%>
    <tr> 
      <td height="25"></td>
      <td class="thinborderNONE">Cutoff date range</td>
      <td colspan="3"><font size="1">
<%
strTemp = WI.fillTextValue("date_fr");
%>
	  
      <input name="date_fr" type="text" size="12" maxlength="12" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
      <a href="javascript:show_calendar('form_.date_fr');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a>
	  - 
      <input name="date_to" type="text" size="12" maxlength="12" value="<%=WI.fillTextValue("date_to")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
      <a href="javascript:show_calendar('form_.date_to');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a>
	  </font>
	  </td>
    </tr>
<%if(strSchCode.startsWith("EAC") && false){%>
    <tr>
      <td height="25"></td>
      <td class="thinborderNONE">SY-Term (optional) </td>
      <td colspan="3" style="font-weight:bold; color:#0000FF; font-size:9px;">
	  	<input name="sy_from" type="text" size="4" maxlength="4" value="<%=WI.fillTextValue("sy_from")%>" class="textbox"
	  		onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  		onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  		onKeyUp='DisplaySYTo("fee_report","sy_from","sy_to")'> - 
			
	  
        <select name="semester">          
			<option value=""></option>
<%
strTemp = WI.fillTextValue("semester");
if(strTemp.compareTo("0") ==0){%>
          <option value="0" selected>Summer</option>
<%}else{%>
          <option value="0">Summer</option>
<%}if(strTemp.compareTo("1") ==0){%>
          <option value="1" selected>1st Sem</option>
<%}else{%>
          <option value="1">1st Sem</option>
<%}if(strTemp.compareTo("2") == 0){%>
          <option value="2" selected>2nd Sem</option>
<%}else{%>
          <option value="2">2nd Sem</option>
<%}if(strTemp.compareTo("3") == 0){%>
          <option value="3" selected>3rd Sem</option>
<%}else{%>
          <option value="3">3rd Sem</option>
<%}%>
        </select> 
		
		&nbsp;&nbsp;
		<input type="checkbox" name="sort_by_sy_term" value="checked" <%=WI.fillTextValue("sort_by_sy_term")%>>
		Display per SY-Term
		
	  </td>
    </tr>
<%}%>
	<!--
<%if(!bolIsBasic) {%>
    <tr id="row_3">
      <td height="25"></td>
      <td class="thinborderNONE">College</td>
      <td colspan="3">
	  <select name="c_index">
		<option value="">All</option>
          <%=dbOP.loadCombo("c_index","c_name"," from college where IS_DEL=0 order by c_name asc",
		  		request.getParameter("c_index"), false)%> 
		</select>	  </td>
    </tr>
<%}else{%>
    <tr id="row_3">
      <td height="25"></td>
      <td class="thinborderNONE">Grade Level</td>
      <td colspan="3">
	  <select name="edu_level">
		<option value="">All</option>
          <%=dbOP.loadCombo("distinct edu_level","edu_level_name"," from bed_level_info order by edu_level", request.getParameter("edu_level"), false)%> 
		</select>	  </td>
    </tr>
<%}%>
 -->   <tr id="row_3"> 
      <td height="25"></td>
      <td width="16%" class="thinborderNONE">Student ID </td>
      <td width="18%"><input name="stud_id" type="text" size="16" value="<%=WI.fillTextValue("stud_id")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">      </td>
      <td colspan="2" class="thinborderNONE">Studen Last Name: 
        <select name="lname_from" onChange="ReloadPage()">
          <%
String[] strConvertAlphabet = {"A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"};
			 strTemp = WI.fillTextValue("lname_from");
			 int j = 0; //displays from and to to avoid conflict -- check the page ;-)
			 for(int i=0; i<26; ++i){
			 	if(strTemp.compareTo(strConvertAlphabet[i]) ==0){
			 		j = i;%>
				 <option selected><%=strConvertAlphabet[i]%></option>
				  <%}else{%>
				 <option><%=strConvertAlphabet[i]%></option>
				  <%}
			}%>
		</select>
	  
	  &nbsp;&nbsp;&nbsp;
<%
if(request.getParameter("date_fr") == null)
	strTemp = " checked";
else if(WI.fillTextValue("show_with_trans").length() > 0) 
	strTemp =" checked";	  
else	
	strTemp = "";
%>
	  <input type="checkbox" name="show_with_trans" value="checked" <%=strTemp%>> Remove if no Balance and no Transaction
	  
	  </td>
    </tr>
    <tr id="row_2"> 
      <td height="25"></td>
      <td class="thinborderNONE">&nbsp;</td>
      <td width="18%">
        <input type="submit" name="12" value=" Generate list " style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="document.all.processing.style.visibility='visible';document.bgColor = '#dddddd'">      </td>
      <td width="27%">
	  <select name="rows_per_page">
	  	<option value="1000000">All in One Page</option>
<%
int iDefValue = 70;
if(strSchCode.startsWith("UC"))
	iDefValue = 84;
	
if(WI.fillTextValue("rows_per_page").length() > 0) 
	iDefValue = Integer.parseInt(WI.fillTextValue("rows_per_page"));
	
for(int i =50; i < 150; ++i){		
	if(iDefValue == i)
		strTemp = " selected";
	else	
		strTemp = "";
%>
		<option value="<%=i%>" <%=strTemp%>><%=i%></option>
<%}%>
	  </select>	  </td>
      <td width="37%" valign="bottom">
	  <%if(vRetResult != null){%>
	  	<a href="javascript:PrintPg();"><img src="../../../images/print.gif" border="0" name="print_hide"></a> <font size="1">click to print list</font>
	  <%}%>	  </td>
    </tr>
  </table>
<%if(vDateToStudList != null && vDateToStudList.size() > 0){
String strDateTime = WI.getTodaysDateTime();
if(WI.fillTextValue("is_basic").length() > 0)
	astrConvertTerm[1] = "Regular";
	
Vector vCollege = new Vector();
String strSQLQuery = "select course_offered.course_code, college.c_code from course_offered join college on (college.c_index = course_offered.c_index) where "+
					" course_offered.is_valid = 1";
java.sql.ResultSet rs = dbOP.executeQuery(strSQLQuery);
while(rs.next()) {
	vCollege.addElement(rs.getString(1));
	vCollege.addElement("_"+rs.getString(2));
}					
rs.close();

int iRowsPerPage = Integer.parseInt(WI.getStrValue(WI.fillTextValue("rows_per_page"), "1000000"));
int iPageNo = 0; 
double dCurRow = 0d;
int iCount = 0;

int iIndexOf = 0;

double dCurrentVal = 0d;
double dRunningBal = 0d;
double dGrandTotal = 0d;

boolean bolNoTransFound = false;

String strLastStudID = "";boolean bolNewPage = false; boolean bolForceBreak = false;

for(int i = 1; i < vDateToStudList.size();){
dCurRow =0d;

if(i > 1){%>
		<DIV style="page-break-after:always" >&nbsp;</DIV>
<%}%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td style="font-size:9px;" width="50%" valign="bottom">Page #: <%=++iPageNo%></td>
      <td align="right" style="font-size:9px;" valign="bottom">Date Time Printed: <%=strDateTime%></td>
    </tr>
  </table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr style="font-weight:bold">
      <td width="10%" class="thinborderTOPBOTTOM" style="font-size:9px;">No.</td> 
      <td width="12%" height="24" class="thinborderTOPBOTTOM" style="font-size:9px;">Student ID</td>
      <td width="33%" class="thinborderTOPBOTTOM" style="font-size:9px;">Student Name</td>
      <td width="10%" class="thinborderTOPBOTTOM" style="font-size:9px;">DEPT</td>
      <td width="14%" class="thinborderTOPBOTTOM" style="font-size:9px;">Last SY/Term</td>
      <td width="7%" class="thinborderTOPBOTTOM" style="font-size:9px;" align="right">Debit</td>
      <td width="7%" class="thinborderTOPBOTTOM" style="font-size:9px;" align="right">Credit</td>
      <td width="7%" class="thinborderTOPBOTTOM" style="font-size:9px;" align="right"> Balance </td>
    </tr>
<%
for(; i < vDateToStudList.size(); i += 9) {
if(dCurRow > iRowsPerPage)
	break;
	
	
	/**
	* I have to make sure system prints complete student in one page.. if broken, i have to move the whole printing to nex tpage. 
	*/
	bolNoTransFound = false;
	double dRunningCount = dCurRow + 1.5d;//add the row by default :: 
	bolForceBreak = false;
	iIndexOf = 0;
	while(vTransDetail.size() > 0) {
		if(iIndexOf == 0) {
			iIndexOf = vTransDetail.indexOf(vDateToStudList.elementAt(i), iIndexOf);
			if(iIndexOf == -1) {
				bolNoTransFound = true;//there is no transaction.. if previous balance is 0, i have to exit.. 
				break;
			}
		}
		else
			iIndexOf = vTransDetail.indexOf(vDateToStudList.elementAt(i), iIndexOf);
			
		//System.out.println(iIndexOf +" :: "+vDateToStudList.elementAt(i));
		if(iIndexOf == -1)
			break;
		++iIndexOf;
		++dRunningCount;
		if(dRunningCount > iRowsPerPage) {
			bolForceBreak = true;
			break;
		}
	}

	if(bolForceBreak)
		break;
	
	

dCurrentVal = 0d;
dRunningBal = 0d;

iIndexOf = vDateFrStudList.indexOf(vDateToStudList.elementAt(i));
if(iIndexOf > -1 && vDateFrStudList.elementAt(iIndexOf + 8) != null) {
	dCurrentVal = Double.parseDouble(ConversionTable.replaceString((String)vDateFrStudList.elementAt(iIndexOf + 8), ",",""));
	
	vDateFrStudList.remove(iIndexOf);vDateFrStudList.remove(iIndexOf);vDateFrStudList.remove(iIndexOf);
	vDateFrStudList.remove(iIndexOf);vDateFrStudList.remove(iIndexOf);vDateFrStudList.remove(iIndexOf);
	vDateFrStudList.remove(iIndexOf);vDateFrStudList.remove(iIndexOf);vDateFrStudList.remove(iIndexOf);
}
//++iCurRow;

//I have to check here if OS balance is 0 and no transaction, i have to skip.. do not show if balance is 0 and no transcation.. 
if(dCurrentVal == 0d && bolNoTransFound && bolRemoveNoBalance)
	continue;
	

dCurRow += 1.5d;
%>
    <tr style="font-weight:bold">
      <td class="thinborderNONE" style="font-size:10px;"><%=++iCount%></td>
      <td height="20" class="thinborderNONE" style="font-size:10px;"><%=vDateToStudList.elementAt(i + 1)%></td>
      <td class="thinborderNONE" style="font-size:10px;"><%=vDateToStudList.elementAt(i + 2)%></td>
      <td class="thinborderNONE" style="font-size:10px;">
	  	<%if(bolIsBasic){%>
			<%=vDateToStudList.elementAt(i + 3)%>
		<%}else{
			iIndexOf = vCollege.indexOf(vDateToStudList.elementAt(i + 3));
			if(iIndexOf == -1)
				strTemp = null;
			else	
				strTemp = ((String)vCollege.elementAt(iIndexOf + 1)).substring(1);
		%>
			<%=WI.getStrValue(strTemp, "&nbsp;")%>
		<%}%>      </td>
      <td class="thinborderNONE" style="font-size:10px;"><%=vDateToStudList.elementAt(i + 6)%> - 
	  	<%=astrConvertTerm[Integer.parseInt((String)vDateToStudList.elementAt(i + 7))]%>	  </td>
      <td class="thinborderNONE" style="font-size:9px;" align="right">&nbsp;</td>
      <td class="thinborderNONE" style="font-size:9px;" align="right">&nbsp;</td>
      <td class="thinborderNONE" style="font-size:9px;" align="right"><%=CommonUtil.formatFloat(dCurrentVal, true)%></td>
    </tr>
<%
dRunningBal = dCurrentVal;
dGrandTotal += dCurrentVal;

while(vTransDetail.size() > 0) {
iIndexOf = vTransDetail.indexOf(vDateToStudList.elementAt(i));
//System.out.println(iIndexOf +" :: "+vDateToStudList.elementAt(i));
if(iIndexOf == -1)
	break;


dCurrentVal = Double.parseDouble(ConversionTable.replaceString((String)vTransDetail.elementAt(iIndexOf + 2), ",",""));
//consider,, debit is +ve and credit is -ve.. 
if(((String)vTransDetail.elementAt(iIndexOf + 8)).equals("1") || ((String)vTransDetail.elementAt(iIndexOf + 8)).equals("3")) //if payment or discount.
	dCurrentVal = -1d * dCurrentVal;
	

dRunningBal += dCurrentVal;
dGrandTotal += dCurrentVal;

++dCurRow;

strTemp = WI.getStrValue((String)vTransDetail.elementAt(iIndexOf + 4), "&nbsp;");
if(strTemp.indexOf("/") == 1)
	strTemp = "0"+strTemp;
//System.out.println(String.valueOf(strTemp.charAt(4)));
if(String.valueOf(strTemp.charAt(4)).equals("/")) {
	strTemp = strTemp.substring(0,3)+"0"+strTemp.substring(3);
}
	
%>
    <tr>
      <td class="thinborderNONE" style="font-size:10px;"><%=strTemp%></td>
      <td class="thinborderNONE" style="font-size:10px;"><%=WI.getStrValue((String)vTransDetail.elementAt(iIndexOf + 1), "&nbsp;")%></td>
      <td colspan="3" class="thinborderNONE" style="font-size:10px;"><%=WI.getStrValue((String)vTransDetail.elementAt(iIndexOf + 3), "&nbsp;")%> <%//=WI.getStrValue((String)vTransDetail.elementAt(iIndexOf + 3), "&nbsp;")%></td>
      <td class="thinborderNONE" style="font-size:9px;" align="right">
	  <%if(dCurrentVal > 0d) {
	  	
		%>
		<%=CommonUtil.formatFloat(dCurrentVal, true)%>
	   <%}else{%>&nbsp;<%}%>
	  </td>
      <td class="thinborderNONE" style="font-size:9px;" align="right">
	  <%if(dCurrentVal < 0d) {dCurrentVal = -1d * dCurrentVal;%>
		<%=CommonUtil.formatFloat(dCurrentVal, true)%>
	   <%}else{%>&nbsp;<%}%>
	  </td>
      <td class="thinborderNONE" style="font-size:9px;" align="right"><%=CommonUtil.formatFloat(dRunningBal, true)%></td>
    </tr>
<%
vTransDetail.remove(iIndexOf);vTransDetail.remove(iIndexOf);vTransDetail.remove(iIndexOf);
vTransDetail.remove(iIndexOf);vTransDetail.remove(iIndexOf);vTransDetail.remove(iIndexOf);
vTransDetail.remove(iIndexOf);vTransDetail.remove(iIndexOf);vTransDetail.remove(iIndexOf);
}%>
<!--
    <tr>
      <td class="thinborderNONE" style="font-size:10px;">&nbsp;</td>
      <td height="20" class="thinborderNONE" style="font-size:10px;">&nbsp;</td>
      <td class="thinborderNONE" style="font-size:10px;">&nbsp;</td>
      <td class="thinborderNONE" style="font-size:10px;">&nbsp;</td>
      <td class="thinborderNONE" style="font-size:10px;">Balance as of Cut Off </td>
      <td class="thinborderNONE" style="font-size:9px;" align="right">&nbsp;</td>
      <td class="thinborderNONE" style="font-size:9px;" align="right">&nbsp;</td>
      <td class="thinborderNONE" style="font-size:9px;" align="right"><%=vDateToStudList.elementAt(i + 8)%></td>
    </tr>
-->



<%
		if(bolNewPage) {
			//bolNewPage = false;
			i += 9;
			break;
		} 
	}//for loop content.%>
	</table>
<%	
}//for loop with header.
%>
  <!--</table>-->
	<%if(strSchCode.startsWith("SPC")){%>
	  <table width="100%" border="0" cellpadding="0" cellspacing="0">
		<tr>
		  <td height="24" align="right"><strong><font size="1">TOTAL BALANCE: <%=CommonUtil.formatFloat(dGrandTotal, true)%>
		  </font></strong><strong></strong></td>
		</tr>
	  </table>
	<%}%>

 <%}//only if vRetResult != null%>
<input type="hidden" name="donot_show">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>