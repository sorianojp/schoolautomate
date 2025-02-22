<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style type="text/css">
  /*this is what we want the div to look like*/
  div.processing{
    display:block;

    /*set the div in the bottom right corner*/
    position:absolute;
    right:8;
	top:8;
	

    
    /*give it some background and border
    background:#007fb7;*/
	background:#FFCC99;
    border:1px solid #ddd;
  }
</style>
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
function ReloadPage()
{
	if(document.form_.is_sa_perexam && document.form_.is_sa_perexam.checked) {
		document.form_.print_all.value ="";
		document.form_.print_pg.value = "";//alert(document.form_.print_by.length)
		if(document.form_.print_by.length > 1)
			document.form_.print_by.selectedIndex = 1;
	}
	if(document.form_.sy_to.value.length < 4 || document.form_.sy_from.value.length < 4) {
		alert("Please enter School Year information.");
		return;
	}
	document.form_.print_all.value ="";
	document.form_.print_pg.value = "";

	document.form_.submit();
}
function CallPrint()
{
	document.form_.print_all.value ="";
	document.form_.print_pg.value = "1";
}
function NextPage() {
	location = "./statement_of_account_UI.jsp?sy_from="+document.form_.sy_from.value+
	"&sy_to="+document.form_.sy_to.value+
	"&semester="+document.form_.semester[document.form_.semester.selectedIndex].value+
	"&pmt_schedule="+
	document.form_.pmt_schedule[document.form_.pmt_schedule.selectedIndex].value;
}
function PrintALL() {
	document.form_.print_all.value ="1";
	document.form_.print_pg.value = "1";
	document.form_.submit();
}
function PrintPg(id_number)
{

	var loadPg = "./statement_of_account_UI_print.jsp?stud_id="+
		id_number+"&sy_from="+document.form_.sy_from.value+
		"&sy_to="+document.form_.sy_to.value+"&semester="+
		document.form_.semester[document.form_.semester.selectedIndex].value+
		"&pmt_schedule="+document.form_.pmt_schedule[document.form_.pmt_schedule.selectedIndex].value;
	if(document.form_.print_final && document.form_.print_final.checked)
		loadPg += "&print_final=1";
	if(document.form_.is_sa_perexam && document.form_.is_sa_perexam.checked)
		loadPg += "&is_sa_perexam=1";
	
	var win=window.open(loadPg,"myfile",'dependent=no,width=800,height=450,top=20,left=20,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function HideLayer(strDiv) {
	if(strDiv == '1'){
		document.form_.show_layer.checked = false;
		document.all.processing.style.visibility='hidden';	
	}
	else
		document.all.processing.style.visibility='visible';	
	
}

</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,java.util.Vector" %>
<%
 
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;

	WebInterface WI = new WebInterface(request);

	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	if (strSchCode == null)
		strSchCode = "";
	//strSchCode = "VMA";
	//strSchCode = "SWU";
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments-ASSESSMENT-assessment batch sched","assessment_sched_batch.jsp");
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
														"Fee Assessment & Payments","ASSESSMENT",request.getRemoteAddr(), 
														"assessment_sched_batch.jsp");	
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
	
if(strErrMsg == null) strErrMsg = "";
String[] strConvertAlphabet = {"A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"};
String[] astrConvertTerm = {"Summer","1st Sem","2nd Sem","3rd Sem","4th Sem"};

boolean bolIsBasic = WI.fillTextValue("is_basic").equals("1");
//if() 
//	bolIsBasic = true;



//get here the list of student to be printed if the print by course is selected.
Vector vRetResult = null;
EnrlReport.StatementOfAccount SOA = new EnrlReport.StatementOfAccount();
if(WI.fillTextValue("print_by").compareTo("1") == 0) {
	vRetResult = SOA.getStudIDBatchPrint(dbOP, request);
	if(vRetResult == null)
		strErrMsg = SOA.getErrMsg();
}

String strStudCSVToPrint = null;
//if print all - i have to print all one by one..
if(WI.fillTextValue("print_all").compareTo("1") == 0 && WI.fillTextValue("show_all_in1page").length() > 0){
	int iMaxPage = vRetResult.size()/3;
	if(WI.fillTextValue("print_option2").length() > 0) {
		//I have to now check if format entered is correct.
		int[] aiPrintPg = SOA.getPrintPage(WI.fillTextValue("print_option2"),iMaxPage);
		if(aiPrintPg == null) 
			strErrMsg = SOA.getErrMsg();
		else {//print here.
			for(int i = 0; i < aiPrintPg.length; ++i) {
				if(strStudCSVToPrint == null)
					strStudCSVToPrint = (String)vRetResult.elementAt(aiPrintPg[i] * 3 - 3);
				else
					strStudCSVToPrint = strStudCSVToPrint+","+(String)vRetResult.elementAt(aiPrintPg[i] * 3 - 3);
			}
		}//end if there is no err Msg.
	}//if(WI.fillTextValue("print_option2").length() > 0) {	
	else {
		//enter this only if page number is selected. -- but call the above only if page range in enter in the input box.
		int iPrintRangeTo = Integer.parseInt(WI.getStrValue(WI.fillTextValue("print_page_range"),"0"));
		int iPrintRangeFr = iPrintRangeTo - 25; 
		if(iPrintRangeFr < 1) 
			iPrintRangeFr = 0;
		if(iPrintRangeTo == iMaxPage && iMaxPage %25 > 0) {
			//i can't subtract just like that.. i have to find the last page count.
			iPrintRangeFr = iMaxPage - iMaxPage%25;
		}
		for(int i = 0,iCount = 0; i < vRetResult.size(); i += 3, ++iCount) {
			if(iPrintRangeTo > 0) {
				if( (iCount + 1) < iPrintRangeFr || (iCount + 1) > iPrintRangeTo)
					continue;
			}

			if(strStudCSVToPrint == null)
				strStudCSVToPrint = (String)vRetResult.elementAt(i);
			else
				strStudCSVToPrint = strStudCSVToPrint+","+(String)vRetResult.elementAt(i);
		}
	}//end of else.. 
	
}//end of printing.. 
if(strStudCSVToPrint != null) {
	dbOP.cleanUP();

	if(strSchCode.startsWith("WNU")) {
		strTemp = "./statement_of_account_WNU_print_perexam_batch.jsp?stud_list="+strStudCSVToPrint+"&sy_from="+
					WI.fillTextValue("sy_from")+"&sy_to="+WI.fillTextValue("sy_to")+"&semester="+WI.fillTextValue("semester")+
					"&pmt_schedule="+WI.fillTextValue("pmt_schedule")+"&is_basic="+WI.fillTextValue("is_basic");
		response.sendRedirect(response.encodeRedirectURL(strTemp));
	}
	else {
		strTemp = "./statement_of_account_batch_print_generic.jsp";
		request.getSession(false).setAttribute("stud_list",strStudCSVToPrint);
		
		strTemp += "?sy_from="+WI.fillTextValue("sy_from")+"&sy_to="+WI.fillTextValue("sy_to")+"&semester="+
			WI.fillTextValue("semester")+"&pmt_schedule="+WI.fillTextValue("pmt_schedule")+
			"&is_basic="+WI.fillTextValue("is_basic")+
			"&print_final="+WI.fillTextValue("print_final")+
			"&course_classification="+WI.fillTextValue("course_classification")+
			"&is_summarized="+WI.fillTextValue("print_summarized");
		response.sendRedirect(response.encodeRedirectURL(strTemp));
	}
	//System.out.println("Redirecting..");
	return;
}
%>

<form name="form_" action="./statement_of_account_UI_main.jsp" method="post">

<%
Vector vCourseInfo = new Vector();
if(WI.fillTextValue("college_index").length() > 0 && strSchCode.startsWith("SWU")){
int iCount = 0;

strTemp = "select course_index, course_code, course_name from course_offered where IS_DEL=0 AND IS_VALID=1  and c_index = "+
	WI.fillTextValue("college_index")+" order by course_code asc";
java.sql.ResultSet rs = dbOP.executeQuery(strTemp);

while(rs.next()) {
	vCourseInfo.addElement(rs.getString(1));
	vCourseInfo.addElement(rs.getString(2));
	vCourseInfo.addElement(rs.getString(3));
}
rs.close();	
if(vCourseInfo != null && vCourseInfo.size() > 0){
%>
	<div id="processing" class="processing">
	<table cellpadding=0 cellspacing=0 border=0 Width=100% Height=100% align=Center class="thinborderALL" bgcolor="#FFCC99">
		  <tr>
			<td valign="top" align="right"><a href="javascript:HideLayer(1)">Close Window X</a></td>
		  </tr>
		  <tr>
			  <td valign="top" align="center"><u><b>List of Courses to exclude Printing</b></u></td>
		  </tr>
		  <tr>
			  <td valign="top">
				<table width="100%" cellpadding="0" cellspacing="0" border="0">						
						<tr>
							<td valign="top">
								<table width="100%" cellpadding="0" cellspacing="0" border="0">
									<%
									for(int i =0; i < vCourseInfo.size(); i += 6){
										strTemp = WI.fillTextValue("_"+iCount);
										if(strTemp.equals((String)vCourseInfo.elementAt(i)))
											strTemp = "checked";
										else
											strTemp = "";
									%>
										<tr>
											<td width="5%"><input type="checkbox" name="_<%=iCount++%>" value="<%=vCourseInfo.elementAt(i)%>" <%=strTemp%>></td>
											<td style="font-size:9px;"><%=vCourseInfo.elementAt(i + 1)%></td>
										</tr>
									<%}%>
								</table>
							</td>
							<td>&nbsp;</td>
							<td valign="top">
								<table width="100%" cellpadding="0" cellspacing="0" border="0">
									<%
									for(int i =3; i < vCourseInfo.size(); i += 6){
										strTemp = WI.fillTextValue("_"+iCount);
										if(strTemp.equals((String)vCourseInfo.elementAt(i)))
											strTemp = "checked";
										else
											strTemp = "";
									%>
										<tr>
											<td width="5%"><input type="checkbox" name="_<%=iCount++%>" value="<%=vCourseInfo.elementAt(i)%>" <%=strTemp%>></td>
											<td style="font-size:9px;"><%=vCourseInfo.elementAt(i + 1)%></td>
										</tr>
									<%}%>
								</table>
							<input type="hidden" name="_count" value="<%=iCount%>">
							</td>
						</tr>					
				</table>
			  </td>
		  </tr>
	</table>
	</div>	
<%}}%>


  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="2" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          PRINT STATEMENT OF ACCOUNT PAGE ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td width="85%" height="25" >&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font size="3"><b><%=WI.getStrValue(strErrMsg)%></b></font></td>
      <%if(vCourseInfo != null && vCourseInfo.size() > 0){%><td valign="top" align="right"><input type="checkbox" name="show_layer" onClick="HideLayer(2)">Show Layer</td><%}%>
    </tr>
  </table>
	
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
<%if(strSchCode.startsWith("VMA") && false){%>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="3">
	  <input type="checkbox" name="print_summarized" value="checked" <%=WI.fillTextValue("print_summarized")%>> 
	  	<font color="#0000FF"><strong>Print Summarized Statement Of Account</strong></font>	  </td>
    </tr>
<%}if(!strSchCode.startsWith("UDMC") && !strSchCode.startsWith("CGH") && !strSchCode.startsWith("MDC") && !strSchCode.startsWith("CLDH") && !strSchCode.startsWith("VMA")){%>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="3">
<%
if(bolIsBasic) 
	strTemp = " checked";
else	
	strTemp = "";
%>  
	  <input type="checkbox" name="is_basic" value="1" <%=strTemp%> onClick="ReloadPage();">
        <font color="#0000FF"><strong>Check if SA is for Grade school</strong></font></td>
    </tr>
<%}if(strSchCode.startsWith("AUF")){%>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="3">
<%
strTemp = WI.fillTextValue("is_sa_perexam");
if(strTemp.equals("1"))
	strTemp = " checked";
else	
	strTemp = "";
%>
	  <input type="checkbox" name="is_sa_perexam" value="1" <%=strTemp%> onClick="ReloadPage();">
        <font color="#FF0000"><strong>Check if SA is per exam period</strong></font></td>
    </tr>
<%}else if(strSchCode.startsWith("WNU")){%>
	<input type="hidden" name="is_sa_perexam" value="1">
<%}%>
    <tr> 
      <td height="25">&nbsp; </td>
      <td height="25">SY/TERM</td>
      <td height="25" colspan="3"> <%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%> <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
        to 
        <%
strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%> <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes"> <select name="semester">
<% 
strTemp = WI.fillTextValue("semester");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sem");

if (!bolIsBasic) {%> 
          <option value="0">Summer</option>
<%if(strTemp.compareTo("1") ==0){%>
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
          <%}
 }else{  // for basic.. 2 teerms only.. %>
 		  <option value="1"> Regular</option>
		  <% if (strTemp.equals("0")) {%> 
		  <option value="0" selected> Summer </option>
		  <%}else{%> 
		  <option value="0"> Summer </option>
		  <%}
 }%> 
        </select> 
        &nbsp;&nbsp;&nbsp; <a href="javascript:ReloadPage();"><img src="../../../images/form_proceed.gif" border="0"></a>
				<%if(strSchCode.startsWith("WNU") || strSchCode.startsWith("DBTC") || strSchCode.startsWith("UPH") || strSchCode.startsWith("VMA") || strSchCode.startsWith("SWU") || strSchCode.startsWith("HTC")) {
		if(request.getParameter("") == null)
			strTemp = "checked";
		else 
			strTemp = WI.fillTextValue("show_all_in1page");%>
		<font  style="font-size:9px; font-weight:bold; color:#0000FF">
			<input type="checkbox" name="show_all_in1page" value="checked" <%=strTemp%>> 
			Show all in 1 page (for batch printing - recommended to print <100 pages at once)		</font>
		<%}%>		</td>
    </tr>
    <tr> 
      <td width="4%" height="35">&nbsp;</td>
      <td height="25">Print by </td>
      <td width="18%" height="25"><select name="print_by" onChange="ReloadPage();">
<%
if( !bolIsBasic && !strSchCode.startsWith("VMA")){%>
         <option value="0">Student</option>
<%}
strTemp = WI.fillTextValue("print_by");
if(strTemp.compareTo("1") ==0){%>
          <option value="1" selected>Course</option>
          <%}else{%>
          <option value="1">Course</option>
          <%}%>
        </select></td>
      <td width="14%">Exam Period </td>
      <td width="47%">
        <select name="pmt_schedule">
		<%if(bolIsBasic){%>
          <%=dbOP.loadCombo("PMT_SCH_INDEX","EXAM_NAME"," from FA_PMT_SCHEDULE where is_del=0 and is_valid=2 order by EXAM_PERIOD_ORDER asc", request.getParameter("pmt_schedule"), false)%> 
		<%}else{%>
          <%=dbOP.loadCombo("PMT_SCH_INDEX","EXAM_NAME"," from FA_PMT_SCHEDULE where is_del=0 and is_valid=1 order by EXAM_PERIOD_ORDER asc", request.getParameter("pmt_schedule"), false)%> 
        <%}%>
		</select>
		
		<% if (bolIsBasic && strSchCode.startsWith("UI")) {
			strTemp = WI.fillTextValue("print_final");
			if (strTemp.length() > 0) 
				strTemp = " checked";
			else
				strTemp = "";
		%> 
			<input type="checkbox" name="print_final" value="1" <%=strTemp%>>
			<font size="1">print Final Statement of Account</font>
		<%}else{%> 
			<!--<input type="hidden" name="print_final">-->		
		<%}%>      </td>
    </tr>
    <%
strTemp = WI.fillTextValue("print_by");
if(strSchCode.startsWith("VMA"))
	strTemp = "1";
	
if(strTemp.compareTo("1") != 0 && !bolIsBasic){%>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp; </td>
      <td height="25">&nbsp; </td>
      <td height="25"><a href="javascript:NextPage();">NEXT PAGE</a></td>
      <td height="25">&nbsp;</td>
    </tr>
    <%}else{
	if(!bolIsBasic){
	if(strSchCode.startsWith("WNU") || strSchCode.startsWith("SWU")){
		if(strSchCode.startsWith("WNU") || strSchCode.startsWith("SWU")){%>
		<tr> 
		  <td height="25">&nbsp;</td>
		  <td height="25"> College </td>
		  <td height="25" colspan="3">
		  <select name="college_index" onChange="ReloadPage();">
		  	<%if(strSchCode.startsWith("SWU")){%><option value="">Please select college</option><%}%>
			  <%=dbOP.loadCombo("c_index","c_name"," from college where is_del = 0 order by c_name", WI.fillTextValue("college_index"), false)%> 
		  </select></td>
		</tr>
	<%}if(strSchCode.startsWith("WNU")){%>
		<tr> 
		  <td height="25">&nbsp;</td>
		  <td width="17%" height="25"> Year level </td>
		  <td height="25" colspan="2"><select name="year_level" onChange="ReloadPage()">
			  <option value="">ALL</option>
			  <%
	strTemp = request.getParameter("year_level");
	if(strTemp == null) strTemp = "";
	if(strTemp.compareTo("1") ==0)
	{%>
			  <option value="1" selected>1st</option>
			  <%}else{%>
			  <option value="1">1st</option>
			  <%}if(strTemp.compareTo("2") == 0){%>
			  <option value="2" selected>2nd</option>
			  <%}else{%>
			  <option value="2">2nd</option>
			  <%}if(strTemp.compareTo("3") ==0){%>
			  <option value="3" selected>3rd</option>
			  <%}else{%>
			  <option value="3">3rd</option>
			  <%}if(strTemp.compareTo("4") ==0){%>
			  <option value="4" selected>4th</option>
			  <%}else{%>
			  <option value="4">4th</option>
			  <%}if(strTemp.compareTo("5") ==0){%>
			  <option value="5" selected>5th</option>
			  <%}else{%>
			  <option value="5">5th</option>
			  <%}if(strTemp.compareTo("6") ==0){%>
			  <option value="6" selected>6th</option>
			  <%}else{%>
			  <option value="6">6th</option>
			  <%}%>
			</select></td>
		  <td height="25">&nbsp;</td>
		</tr>
	<%}
	}if(!strSchCode.startsWith("WNU")){//show course only if not wnu.. %>
		<tr>
		  <td height="25">&nbsp;</td>
		  <td height="25">Course Prog. </td>
		  <td height="25" colspan="3">
		<select name="course_classification">
          <option value=""></option>
          <%=dbOP.loadCombo("cc_index","cc_name"," from cclassification where IS_DEL=0 order by cc_name", request.getParameter("course_classification"), false)%> 
        </select>
		</td>
    </tr>
		<tr> 
		  <td height="25">&nbsp;</td>
		  <td height="25"> Course </td>
		  <td height="25" colspan="3"><select name="course_index" onChange="ReloadPage();" style="width:500px">
			  <option value="0">Select Any</option>
			  <%
	//for all course listing strTemp = " from course_offered where IS_DEL=0 AND IS_VALID=1 order by course_name asc"
	strErrMsg = "";
	if(WI.fillTextValue("college_index").length() > 0)
		strErrMsg = " and c_index = "+WI.fillTextValue("college_index");
	if(WI.fillTextValue("course_classification").length() > 0)
		strErrMsg = " and cc_index = "+WI.fillTextValue("course_classification");
	strTemp = " from course_offered where IS_DEL=0 AND IS_VALID=1 "+strErrMsg+" order by course_name asc";
	%>
			  <%=dbOP.loadCombo("course_index","course_name",strTemp, request.getParameter("course_index"), false)%> 
			</select></td>
		</tr>
		<tr> 
		  <td height="25">&nbsp;</td>
		  <td height="25">Major</td>
		  <td height="25" colspan="3"> <select name="major_index">
			  <option value="">ALL</option>
			  <%
	strTemp = request.getParameter("course_index");
	if(strTemp != null && strTemp.compareTo("0") != 0)
	{
	strTemp = " from major where is_del=0 and course_index="+strTemp ; 
	%>
			  <%=dbOP.loadCombo("major_index","major_name",strTemp, request.getParameter("major_index"), false)%> 
			  <%}%>
			</select></td>
		</tr>
		<tr> 
		  <td height="25">&nbsp;</td>
		  <td width="17%" height="25"> Year level </td>
		  <td height="25" colspan="2"><select name="year_level" onChange="ReloadPage()">
			  <option value="">ALL</option>
			  <%
	strTemp = request.getParameter("year_level");
	if(strTemp == null) strTemp = "";
	if(strTemp.compareTo("1") ==0)
	{%>
			  <option value="1" selected>1st</option>
			  <%}else{%>
			  <option value="1">1st</option>
			  <%}if(strTemp.compareTo("2") == 0){%>
			  <option value="2" selected>2nd</option>
			  <%}else{%>
			  <option value="2">2nd</option>
			  <%}if(strTemp.compareTo("3") ==0){%>
			  <option value="3" selected>3rd</option>
			  <%}else{%>
			  <option value="3">3rd</option>
			  <%}if(strTemp.compareTo("4") ==0){%>
			  <option value="4" selected>4th</option>
			  <%}else{%>
			  <option value="4">4th</option>
			  <%}if(strTemp.compareTo("5") ==0){%>
			  <option value="5" selected>5th</option>
			  <%}else{%>
			  <option value="5">5th</option>
			  <%}if(strTemp.compareTo("6") ==0){%>
			  <option value="6" selected>6th</option>
			  <%}else{%>
			  <option value="6">6th</option>
			  <%}%>
			</select></td>
		  <td height="25">&nbsp;</td>
		</tr>
<%}//show only if not wnu.. 
}//show if basic
   else {%>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Education Level</td>
      <td colspan="3">
	  <%if(strSchCode.startsWith("WNU")){%>
	  <select name="edu_level" onChange="ReloadPage()">
          <%=dbOP.loadCombo("distinct edu_level","EDU_LEVEL_NAME"," from BED_LEVEL_INFO order by edu_LEVEL",WI.fillTextValue("edu_level"),false)%> 
	  </select>
	  <%}else{%>
	  <select name="year_level" onChange="ReloadPage()">
          <%=dbOP.loadCombo("G_LEVEL","EDU_LEVEL_NAME +' - '+ LEVEL_NAME"," from BED_LEVEL_INFO order by G_LEVEL",WI.fillTextValue("year_level"),false)%> 
      </select>	
	  - 
	  <select name="section_name" onChange="ReloadPage()">
	  <option value=""></option>
          <%=dbOP.loadCombo("distinct e_sub_section.section","e_sub_section.section"," from e_sub_section where offering_sy_from = "+WI.fillTextValue("sy_from")+
		  	" and offering_sem = "+WI.fillTextValue("semester")+" and exists (select * from subject where sub_index = e_sub_section.sub_index and is_del = 2) "+
			" and exists (select * from enrl_final_cur_list where sub_sec_index = e_sub_section.sub_sec_index and is_valid = 1 and current_year_level = "+
			WI.getStrValue(WI.fillTextValue("year_level"), "1")+")",WI.fillTextValue("section_name"),false)%> 
	  </select>
	  <%}%>	  </td>
    </tr>
<%}//show only if basic.%>   	
		
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">Student ID </td>
      <td height="25">	  
		  <input name="stud_id" type="text" size="24" maxlength="24" value="<%=WI.fillTextValue("stud_id")%>" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">		</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="4" height="25">Print students whose lastname starts with 
        <select name="lname_from" onChange="ReloadPage()">
          <%
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
        to 
        <select name="lname_to" onChange="ReloadPage()">
          <option value="0"></option>
          <%
 strTemp = WI.fillTextValue("lname_to");
 
 for(int i=++j; i<26; ++i){
 if(strTemp.compareTo(strConvertAlphabet[i]) ==0){%>
          <option selected><%=strConvertAlphabet[i]%></option>
          <%}else{%>
          <option><%=strConvertAlphabet[i]%></option>
          <%}
}%>
        </select> </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="3">&nbsp; </td>
    </tr>
    <%
if(vRetResult != null && vRetResult.size() > 0){%>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25" colspan="4"><font size="3">TOTAL STUDENTS TO BE PRINTED 
        : <strong><%=vRetResult.size()/3%></strong></font></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">PRINT OPTION 1</td>
      <td height="25" colspan="3"> <select name="print_page_range">
          <option value="">ALL</option>
          <%
	  strTemp = WI.fillTextValue("print_page_range");
	  int iTemp = vRetResult.size()/3;
	  int iLastCount = 0;
	  for(int i = 1; i <= iTemp;){
	  	i += 25; //in batch of 25
		if(i > iTemp)
			iLastCount = iTemp;
		else	
			iLastCount += 25;
		 if(strTemp.compareTo(Integer.toString(iLastCount)) == 0){%>
          <option value="<%=iLastCount%>" selected><%=i - 25%> to <%=iLastCount%></option>
          <%}else{%>
          <option value="<%=iLastCount%>"><%=i - 25%> to <%=iLastCount%></option>
          <%}
	  }%>
        </select></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td valign="top">PRINT OPTION 2</td>
      <td height="25" colspan="3" valign="top"><input name="print_option2" type="text" size="16" maxlength="32" 
	  value="<%=WI.fillTextValue("print_option2")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
        <br> <font color="#0099FF"> <strong>(Enter page numbers and/or page ranges 
        separated by commas. For ex: 1,3,5-12)</strong></font></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="3"> <input type="image" src="../../../images/form_proceed.gif" onClick="CallPrint()"> 
        <font size="1">click to display student list to print.</font></td>
    </tr>
    <%}//only if vRetResult is not null;

	}//if print_by is not student
%>
  </table>
<%
if(vRetResult != null && vRetResult.size() > 0 && WI.fillTextValue("print_pg").compareTo("1") == 0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="1" bgcolor="#000000">
    <tr bgcolor="#FFFFFF"> 
      <td height="25" colspan="4" align="right"><a href="javascript:PrintALL();"> 
        <img src="../../../images/print.gif" border="0"></a> <font size="1">Click 
        to print</font>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
    </tr>
    <tr bgcolor="#999999"> 
      <td height="25" colspan="4" align="center"><B>LIST OF STUDENT FOR PRINTING.</B></td>
    </tr>
    <tr bgcolor="#ffff99"> 
      <td height="25" colspan="2" align="center"><strong>STUDENT ID</strong></td>
      <td width="40%" align="center"><strong>STUDENT NAME</strong></td>
      <td width="18%" align="center"><strong>PRINT</strong></td>
    </tr>
    <%
 for(int i = 0,iCount=1; i < vRetResult.size(); i += 3,++iCount){%>
    <tr bgcolor="#FFFFFF"> 
      <td width="6%"><%=iCount%>.</td>
      <td width="36%" height="25">&nbsp;&nbsp;<%=(String)vRetResult.elementAt(i)%></td>
      <td>&nbsp;&nbsp;<%=(String)vRetResult.elementAt(i + 1)%></td>
      <td align="center"><a href='javascript:PrintPg("<%=(String)vRetResult.elementAt(i)%>");'><img src="../../../images/print.gif" border="0"></a></td>
    </tr>
    <%}%>
  </table>
<%}//end of vRetResult display.%>







  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25">&nbsp;</td>
    </tr>
    <tr bgcolor="#A49A6A"> 
      <td height="25">&nbsp;</td>
    </tr>
  </table>
  
 
 
  <input type="hidden" name="print_pg" value="">  
  <input type="hidden" name="print_all" value="">
</form>

<%
//if print all - i have to print all one by one.. 
if(WI.fillTextValue("print_all").compareTo("1") == 0 && vRetResult != null && vRetResult.size() > 0){
int iMaxPage = vRetResult.size()/3;
if(WI.fillTextValue("print_option2").length() > 0) {
//I have to now check if format entered is correct.
	int[] aiPrintPg = SOA.getPrintPage(WI.fillTextValue("print_option2"),iMaxPage);
	if(aiPrintPg == null) {
		strErrMsg = SOA.getErrMsg();%> 
		<script language="JavaScript">alert("<%=strErrMsg%>");</script><%
	}
	else {//print here.
		int iCount = 0; %>
		<script language="JavaScript">
		var countInProgress = 0;
		<%
		for(int i = 0; i < aiPrintPg.length; ++i,++iCount) {%>
			function PRINT_<%=iCount%>() {
				var pgLoc = "./statement_of_account_UI_print.jsp?stud_id=<%=(String)vRetResult.elementAt(aiPrintPg[i] * 3 - 3)%>"+
					"&sy_from=<%=WI.fillTextValue("sy_from")%>&sy_to=<%=WI.fillTextValue("sy_to")%>&semester=<%=WI.fillTextValue("semester")%>"+
					"&pmt_schedule=<%=WI.fillTextValue("pmt_schedule")%>" + 
				    "&print_final=<%=WI.fillTextValue("print_final")%>";
				//alert("I am in count <%=iCount%>");
				
				window.open(pgLoc);
			}
		<%}%>
		function callPrintFunction() {
			//alert(countInProgress);
			if(eval(countInProgress) > <%=iCount-1%>)
				return;
			eval('this.PRINT_'+countInProgress+'()');//alert(countInProgress);
			countInProgress = eval(countInProgress) + 1;//alert(printCountInProgress);
		
			window.setTimeout("callPrintFunction()", 10000);
		}
		this.callPrintFunction();
		</script>
	<%
	}
}
else {
	//enter this only if page number is selected. -- but call the above only if page range in enter in the input box.
	int iPrintRangeTo = Integer.parseInt(WI.getStrValue(WI.fillTextValue("print_page_range"),"0"));
	int iPrintRangeFr = iPrintRangeTo - 25; if(iPrintRangeFr < 1) iPrintRangeFr = 0;
	if(iPrintRangeTo == iMaxPage && iMaxPage %25 > 0) {
		//i can't subtract just like that.. i have to find the last page count.
		iPrintRangeFr = iMaxPage - iMaxPage%25;	
	}
	%>
		<script language="JavaScript">
			var printCountInProgress = 0;
			var totalPrintCount = 0;
			<%int iCount = 0; 
			for(int i = 0; i < vRetResult.size(); i += 3,++iCount) {
				if(iPrintRangeTo > 0) {
					if( (iCount + 1) < iPrintRangeFr || (iCount + 1) > iPrintRangeTo)
						continue;				
				}%>
				
				function PRINT_<%=iCount%>() {
					var pgLoc = "./statement_of_account_UI_print.jsp?stud_id=<%=(String)vRetResult.elementAt(i)%>"+
						"&sy_from=<%=WI.fillTextValue("sy_from")%>&sy_to=<%=WI.fillTextValue("sy_to")%>&semester=<%=WI.fillTextValue("semester")%>"+
						"&pmt_schedule=<%=WI.fillTextValue("pmt_schedule")%>" + 
					    "&print_final=<%=WI.fillTextValue("print_final")%>";
			
					window.open(pgLoc);
				}//end of printing function.
			<%
		}//end of for loop.
		
		//for(int i = 0;  i < vRetResult.size(); i += 2){
		%>totalPrintCount = <%=iCount%>;
		printCountInProgress = <%=iPrintRangeFr%>;
		<%if(iPrintRangeTo == 0)
			iPrintRangeTo = iCount;
		%>
		totalPrintCount = <%=iPrintRangeTo%>;
		function callPrintFunction() {
			//alert(printCountInProgress);
			if(eval(printCountInProgress) >= eval(totalPrintCount))
				return;
			eval('this.PRINT_'+printCountInProgress+'()');//alert(printCountInProgress);
			printCountInProgress = eval(printCountInProgress) + 1;//alert(printCountInProgress);
		
			window.setTimeout("callPrintFunction()", 10000);
		}
		//function PrintALL(strIndex) {
			//if(eval(strIndex) < eval(totalPrintCount))
		//}	
			this.callPrintFunction();
		</script>

<%}//end if print_option2 is not entered.

}//end if print is called.%>
</body>
</html>
<%
dbOP.cleanUP();
%>
