<%
String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript">
function CheckValidHour() {
	var vTime =document.form_.time_from_hr.value 
	if(eval(vTime) > 12 || eval(vTime) == 0) {
		alert("Time should be >0 and <= 12");
		document.form_.time_from_hr.value = "12";
	}
	vTime =document.form_.time_to_hr.value 
	if(eval(vTime) > 12 || eval(vTime) == 0) {
		alert("Time should be >0 and <= 12");
		document.form_.time_to_hr.value = "12";
	}
}
function CheckValidMin() {
	if(eval(document.form_.time_from_min.value) > 59) {
		alert("Time can't be > 59");
		document.form_.time_from_min.value = "00";
	}
	if(eval(document.form_.time_to_min.value) > 59) {
		alert("Time can't be > 59");
		document.form_.time_to_min.value = "00";
	}
}
	function DisplayAll(){
		document.form_.showAll.value = "1";
		document.form_.print_page.value = "";
		document.form_.info_index.value= "";
		document.form_.page_action.value = "";
		document.form_.prepareToEdit.value = "";
		document.form_.edit_section_name.value= "";
		document.form_.submit();
	}
	
	function PrintPg(){
		document.form_.print_page.value= "1";
		document.form_.submit();
	}
	function PrepareToEdit(strInfoIndex, strSectionName){
		document.form_.prepareToEdit.value = "1";
		document.form_.info_index.value= strInfoIndex;
		document.form_.edit_section_name.value= strSectionName;

		document.form_.showAll.value = "1";
		document.form_.submit();
	}
	function PageAction(strAction, strInfoIndex){
		if(strInfoIndex.length > 0)
			document.form_.info_index.value= strInfoIndex;
		document.form_.page_action.value = strAction;
		document.form_.showAll.value = "1";
		document.form_.submit();
	}
	function Cancel() {
		this.DisplayAll();
	}
	//Ajax Operation here. 
	function updateOfferingCount (strIndex) {
		return;
	}

function UpdateSectionName(strOrigSection, strInfoIndex) {
		return;
}

//Ajax Implementation.. 
function ToggleForceCloseOpen(strSubSecRef) {
	return;
}
function UpdateCapacity(strSubSecRef) {
	return;
}
function PageSubmit(e) {//submit page on ENTER
	if(e.keyCode == 13) 
		DisplayAll();
}
</script>
<body bgcolor="#D2AE72" onLoad="document.form_.scroll_sub.focus()">
<%@ page language="java" import="utility.*,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	String strErrMsg = "";
	String strTemp = null;
	WebInterface WI = new WebInterface(request);

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Enrollment-Class program per subject","class_program_persub.jsp");
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
int iAccessLevel = 2;

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
String strPrepareToEdit = "0";


Vector vRetResult = null; Vector vAddlInfo = null; int iIndexOf = 0; String strCapacity = null;
enrollment.SubjectSection SS = new enrollment.SubjectSection();
if (WI.fillTextValue("showAll").length() >  0) {
	vRetResult = SS.operateOnCPPerSub(dbOP, request,4);
	if (vRetResult == null && strErrMsg == null)
		strErrMsg = " No Record Found";
	else		
		vAddlInfo = (Vector)vRetResult.remove(0);
}


boolean bolIsPhilCST = strSchCode.startsWith("PHILCST");
String strSYFrom = (String)request.getParameter("sy_from"); 
String strSem    = (String)request.getParameter("semester");

String[] astrOpenCloseStat = {"&nbsp;","Y"};

boolean bolAllowAdjustCapacity = false;
strTemp = dbOP.getResultOfAQuery("select prop_val from read_property_file where prop_name = 'ADVISING_CAPACITY'", 0);
if(strTemp != null && strTemp.equals("1"))
	bolAllowAdjustCapacity = true;
else
	bolAllowAdjustCapacity = false;

%>

<form name="form_" action="./class_program_persub_restricted.jsp" method="post">
<table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="6"><div align="center"><font color="#FFFFFF"><strong>:::: 
          CLASS PROGRAM - PER SUBJECT - VIEW/EDIT/DELETE/ PRINT PAGE ::::</strong></font></div></td>
    </tr>
  </table>

  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="2%">&nbsp;</td>
      <td colspan="3" height="25"><strong><font size="3"><%=WI.getStrValue(strErrMsg,"")%></font></strong></td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td width="35%" valign="bottom">School year : 
        <%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");

strSYFrom = strTemp;%> <input name="sy_from" type="text" class="textbox" id="sy_from"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("form_","sy_from","sy_to")' value="<%=strTemp%>" size="4" maxlength="4">
        to 
<%
strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%> <input name="sy_to" type="text" class="textbox" id="sy_to"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=strTemp%>" size="4" maxlength="4"
	  readonly="yes"> &nbsp;&nbsp;&nbsp; &nbsp;</td>
      <td width="20%" valign="bottom">Term : 
<%
strTemp = WI.fillTextValue("semester");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sem");

strSem = strTemp;
%>
        <select name="semester" onChange="document.form_.showAll.value='';document.form_.submit();">
 	  		<%=CommonUtil.constructTermList(dbOP, request, strTemp)%>
        </select> </td>
      <td width="43%" valign="bottom"><a href="javascript: DisplayAll()"><img src="../../../images/form_proceed.gif"border="0"></a></td>
    </tr>
    <tr> 
      <td colspan="4"><hr size="1"></td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td colspan="3" valign="bottom">Subject Code : <font size="1"> 
        <input type="text" name="scroll_sub" size="16" style="font-size:9px" 
	  onKeyUp="AutoScrollListSubject('scroll_sub','sub_index',true,'form_'); PageSubmit(event);">
        (enter subject code to scroll the list)</font></td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td colspan="3" valign="bottom"><select name="sub_index" title="SELECT A  SUBJECT"
	  	style="font-size:11px;font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;" onChange="DisplayAll()">
          <%=dbOP.loadCombo("sub_index","sub_code +'&nbsp;&nbsp;&nbsp;('+sub_name+')' as s_code"," from subject where is_del=0 "+
		  		" and exists (select * from e_sub_section where sub_index = subject.sub_index and e_sub_section.is_valid = 1 and "+
				"offering_sy_from = "+strSYFrom+" and offering_sem = "+strSem+") order by s_code",WI.fillTextValue("sub_index"), false)%> </select></td>
    </tr>
    <tr> 
      <td colspan="4" height="19">&nbsp;</td>
    </tr>
  </table>
<% if (vRetResult != null && vRetResult.size() > 0) {
Vector vSubjectUnit = SS.getSubjectUnits(dbOP);
if(vSubjectUnit == null)
	vSubjectUnit = new Vector();//System.out.println(vRetResult);
String strTotalUnits = null;
%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="60%" height="25">&nbsp;&nbsp; <strong>Total Schedules Found: 
        <%=vRetResult.size()/11%></strong></td>
      <td width="40%">&nbsp;</td>
    </tr>
  </table>  
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#B9B292"> 
      <td height="25" colspan="12" class="thinborder"><div align="center">FINAL SCHEDULE OF CLASSES<strong></strong></div></td>
    </tr>
  </table>  
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr align="center" style="font-weight:bold">
<%if(bolIsPhilCST){%>
      <td width="5%" class="thinborder" style="font-size:9px; font-weight:bold" align="center"><font size="1">OFFERING CODE</font></td> 
      <%}%>
      <td width="11%" class="thinborder"><font size="1">OFFERED BY</font></td>
      <td width="11%" height="25" class="thinborder"><font size="1">SUBJECT CODE</font></td>
      <td width="19%" class="thinborder"><font size="1">DESCRIPTION</font></td>
      <td width="5%" class="thinborder"><font size="1">TOTAL UNITS</font></td>
      <td width="10%" class="thinborder"><font size="1">SECTION</font></div></td>
      <td class="thinborder"><font size="1">SCHEDULE</font></div></td>
      <td width="5%" class="thinborder"><font size="1">ROOM #</font></div></td>
      <td width="5%" class="thinborder"><font size="1"># Enrolled</font></td>
<%if(bolAllowAdjustCapacity){%>
      <td width="5%" class="thinborder"><font size="1">Max Capacity</font></td>
<%}%>
       <td width="5%" class="thinborder" align="center"><font size="1">Is Reserved?</font></td>
     <td width="5%" height="25" class="thinborder"><font size="1">Is Closed?</font></td>
    </tr>
    <%
	String strEditRowCol = null; int iCount = 0; String strIsClosed = ""; int iEnrolled = 0; int iMaxCapacity = 0;
	if(vAddlInfo == null)
		vAddlInfo = new Vector();
		
	for(int i = 0 ; i < vRetResult.size() ; i+=13){ //System.out.println((String)vRetResult.elementAt(i));
	
		iIndexOf = vSubjectUnit.indexOf((String)vRetResult.elementAt(i));
		if(iIndexOf > -1)
			strTotalUnits = (String)vSubjectUnit.elementAt(iIndexOf + 1);
		else	
			strTotalUnits = "&nbsp;";
		
		//System.out.println(vRetResult.elementAt(i + 11));
		//////////// check if closed ////////////////////////////
		iIndexOf = vAddlInfo.indexOf(new Integer((String)vRetResult.elementAt(i + 4)));
		if(iIndexOf == -1) {
			strCapacity = "&nbsp;";
			strTemp = "&nbsp;";
		}
		else  {
			strTemp = astrOpenCloseStat[Integer.parseInt((String)vAddlInfo.elementAt(iIndexOf + 2))];
			strCapacity = WI.getStrValue((String)vAddlInfo.elementAt(iIndexOf + 1), "&nbsp;");
		}
		strEditRowCol = "";
		strErrMsg = WI.getStrValue((String)vRetResult.elementAt(i + 10), "0");
		if(strErrMsg.equals("&nbsp;"))
			strErrMsg = "0";
			
		iEnrolled = Integer.parseInt(strErrMsg); 
		iMaxCapacity = -1; strIsClosed = "&nbsp;";
		if(strCapacity != null && strCapacity.length() > 0 && !strCapacity.equals("&nbsp;")) {
			iMaxCapacity = Integer.parseInt(strCapacity); 
			if(iEnrolled >= iMaxCapacity) {
				strIsClosed   = "Y";
				strEditRowCol = "style='color:#FF0000'";
			}
		}
		/////////////end of checking closed.

	  	
	%>
    <tr <%=strEditRowCol%>>
<%if(bolIsPhilCST){%>
      <td class="thinborder">
	  		<input name="offering_count<%=iCount%>" type="text" size="6" class="textbox_noborder2"
			onBlur="updateOfferingCount(<%=iCount%>);style.backgroundColor='white'"
			value="<%=WI.getStrValue(SS.convertSubSecIndexToOfferingCount(dbOP, request, (String)vRetResult.elementAt(i+4), strSYFrom, strSem, strSchCode))%>"
			onfocus="style.backgroundColor='#D3EBFF'">
		<input type="hidden" name="info_index<%=iCount%>" value="<%=(String)vRetResult.elementAt(i + 4)%>">
			  </td> 
      <%}%>
      <td class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i + 12), "&nbsp;")%></td>
      <td height="25" class="thinborder"><font size="1"><%=(String)vRetResult.elementAt(i+2)%></font></td>
      <td class="thinborder"><font size="1"><%=(String)vRetResult.elementAt(i+3)%></font></td>
      <td class="thinborder"><%=strTotalUnits%></td>
      <td class="thinborder"><font size="1"><label id="_<%=i%>" onDblClick="UpdateSectionName('<%=(String)vRetResult.elementAt(i+1)%>','<%=(String)vRetResult.elementAt(i+4)%>')"><%=(String)vRetResult.elementAt(i+1)%></label></font></td>
      <td class="thinborder"><font size="1"><%=(String)vRetResult.elementAt(i+5)%></font></td>
      <td class="thinborder"><font size="1"><%=(String)vRetResult.elementAt(i+7)%></font></td>
      <td class="thinborder"><%=vRetResult.elementAt(i + 10)%></td>
<%if(bolAllowAdjustCapacity){%>
      <td class="thinborder" align="center"><%=strCapacity%></td>
<%}%>      <td class="thinborder" align="center"><font style="font-weight:bold; font-size:12px; color:#FF0000"><%=strTemp%></font></td>
      <td class="thinborder" align="center"><font style="font-weight:bold; font-size:12px; color:#FF0000"><%=strIsClosed%></font></td>
    </tr>
    <%}//end for loop %>
  </table>
<%} // if (vRetResult != null && vRetResult.size() > 0)%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF">
    <tr > 
      <td height="25">&nbsp;</td>
    </tr>
    <tr bgcolor="#A49A6A"> 
      <td height="25" >&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="showAll">
<input type="hidden" name="print_page">

<input type="hidden" name="page_action">
<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
<input type="hidden" name="edit_section_name" value="<%=WI.fillTextValue("edit_section_name")%>">

<input type="hidden" name="get_no_conflict" value="1">
<input type="hidden" name="update_dcc"><!--update do not check conflict -->


<input type="hidden" name="new_sec">
<input type="hidden" name="sub_sec_i">

<!-- add in pages with subject scroll -->
<%=dbOP.constructAutoScrollHiddenField()%>

</form>

</body>
</html>
<%
dbOP.cleanUP();
%>
