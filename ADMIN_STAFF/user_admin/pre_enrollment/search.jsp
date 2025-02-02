<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Search Student</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/reportlink.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
function PrintPg() {
	document.bgColor = "#FFFFFF";
   	document.getElementById('myADTable1').deleteRow(0);
	
   	document.getElementById('myADTable2').deleteRow(0);
   	document.getElementById('myADTable2').deleteRow(0);
   	document.getElementById('myADTable2').deleteRow(0);
   	document.getElementById('myADTable2').deleteRow(0);
   	document.getElementById('myADTable2').deleteRow(0);
   	document.getElementById('myADTable2').deleteRow(0);
   	document.getElementById('myADTable2').deleteRow(0);
   	document.getElementById('myADTable2').deleteRow(0);
   	document.getElementById('myADTable2').deleteRow(0);
   	document.getElementById('myADTable2').deleteRow(0);
   	document.getElementById('myADTable2').deleteRow(0);
   	document.getElementById('myADTable2').deleteRow(0);
	
   	document.getElementById('myADTable3').deleteRow(0);
   	document.getElementById('myADTable3').deleteRow(0);
   	document.getElementById('myADTable3').deleteRow(0);
	
   	document.getElementById('myADTable4').deleteRow(0);
	
   	document.getElementById('myADTable5').deleteRow(0);

   	alert("Click OK to print this page");
	window.print();//called to remove rows, make bk white and call print.
}
function Search()
{
	document.form_.search_.value = "1";
	document.form_.fee_name.value = document.form_.fee_ref[document.form_.fee_ref.selectedIndex].text;
//	document.form_.print_pg.value = "";
	this.SubmitOnce("form_");
}
</script>

<body bgcolor="#D2AE72" topmargin="0" bottommargin="0">
<%@ page language="java" import="utility.*,enrollment.PreEnrollment,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String strTemp = null;
	Vector vRetResult = null;

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"System Administration-Set Parameters-Pre enrollment","search.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		//ErrorLog.logError(exp,"admission_application_sch_veiwall.jsp","While Opening DB Con");

		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
	}

String[] astrDropListEqual = {"Equal to","Starts with","Ends with","Contains"};
String[] astrDropListValEqual = {"equals","starts","ends","contains"};

String[] astrSortByName    = {"Student ID","Lastname","Firstname","Gender","year"};
String[] astrSortByVal     = {"id_number","lname","fname","gender","year_l"};


int iSearchResult = 0;

PreEnrollment searchPE = new PreEnrollment(request);
if(WI.fillTextValue("search_").compareTo("1") == 0){
	vRetResult = searchPE.searchPreEnrollment(dbOP);
	if(vRetResult == null)
		strErrMsg = searchPE.getErrMsg();
	else	
		iSearchResult = searchPE.getSearchCount();
}

%>
<form action="./search.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" id="myADTable1">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="4" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>::::
          SEARCH STUDENT PAGE ::::</strong></font></div></td>
    </tr>
  </table>

  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" id="myADTable2">
    <tr> 
      <td height="25" colspan="6">&nbsp;&nbsp;&nbsp;&nbsp;<font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
    
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="5"><strong><font size="1" color="#0000FF">NOTE : Pre enrollment search is for old student only. </font></strong></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="3">Show students: 
        <select name="stud_status" style="font-size:11px;">
	  		<option value="0">Not applicable</option>
			<option value="1">with downpayment</option>
			<option value="2">without downpayment</option>
      </select>      </td>
      <td>Fee Name </td>
      <td><select name="fee_ref" style="font-size:9px;background:#DFDBD2;">
<%
//I have to get the pre-enrollment fee.
String strSYFrom = WI.fillTextValue("sy_from");
String strSYTo   = WI.fillTextValue("sy_to");
String strSem    = WI.fillTextValue("semester");

if(strSYFrom.length() ==0) {
	strSYFrom = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
	strSYTo   = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
	strSem    = (String)request.getSession(false).getAttribute("cur_sem");

}	
strTemp = " from FA_OTH_SCH_FEE " +
        "join fa_schyr on (fa_oth_sch_fee.sy_index = fa_schyr.sy_index) " +
        "where sy_from=" + strSYFrom +
        " and FA_OTH_SCH_FEE.is_valid=1 and FA_OTH_SCH_FEE.is_del=0 and "+
		"fee_name like 'Application%' order by fee_name asc";

%>
         <%=dbOP.loadCombo("OTHSCH_FEE_INDEX","fee_name,amount",strTemp,WI.fillTextValue("fee_ref"), false)%>
      </select></td>
    </tr>
    <tr> 
      <td width="3%" height="25">&nbsp;</td>
      <td width="11%">Student ID </td>
      <td width="10%"><select name="id_number_con" style="font-size:10px;">
          <%=searchPE.constructGenericDropList(WI.fillTextValue("id_number_con"),astrDropListEqual,astrDropListValEqual)%> </select> </td>
      <td width="26%"><input type="text" name="id_number" value="<%=WI.fillTextValue("id_number")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="12"></td>
      <td width="8%">SY-SEM</td>
      <td width="42%"><input name="sy_from" type="text" size="4" value="<%=strSYFrom%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeyPress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("form_","sy_from","sy_to")' maxlength=4>
to
  <input name="sy_to" type="text" size="4" value="<%=strSYTo%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes">
&nbsp;&nbsp;
<select name="semester">
  <option value="">N/A</option>
  <%
strTemp = strSem;
if(strTemp.compareTo("1") ==0){%>
  <option value="1" selected>1st Sem</option>
  <%}else{%>
  <option value="1">1st Sem</option>
  <%}if(strTemp.compareTo("2") ==0){%>
  <option value="2" selected>2nd Sem</option>
  <%}else{%>
  <option value="2">2nd Sem</option>
  <%}if(strTemp.compareTo("3") ==0){%>
  <option value="3" selected>3rd Sem</option>
  <%}else{%>
  <option value="3">3rd Sem</option>
  <%}if(strTemp.compareTo("0") ==0){%>
  <option value="0" selected>Summer</option>
  <%}else{%>
  <option value="0">Summer</option>
  <%}%>
</select></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Lastname</td>
      <td><select name="lname_con" style="font-size:10px;">
          <%=searchPE.constructGenericDropList(WI.fillTextValue("lname_con"),astrDropListEqual,astrDropListValEqual)%> </select></td>
      <td><input type="text" name="lname" value="<%=WI.fillTextValue("lname")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="12"></td>
      <td>Year</td>
      <td><select name="year_level">
        <option value="">N/A</option>
        <%
strTemp = WI.fillTextValue("year_level");
if(strTemp.compareTo("1") ==0)
{%>
        <option value="1" selected>1st</option>
        <%}else{%>
        <option value="1">1st</option>
        <%}if(strTemp.compareTo("2") ==0){%>
        <option value="2" selected>2nd</option>
        <%}else{%>
        <option value="2">2nd</option>
        <%}if(strTemp.compareTo("3") ==0)
{%>
        <option value="3" selected>3rd</option>
        <%}else{%>
        <option value="3">3rd</option>
        <%}if(strTemp.compareTo("4") ==0)
{%>
        <option value="4" selected>4th</option>
        <%}else{%>
        <option value="4">4th</option>
        <%}if(strTemp.compareTo("5") ==0)
{%>
        <option value="5" selected>5th</option>
        <%}else{%>
        <option value="5">5th</option>
        <%}if(strTemp.compareTo("6") ==0)
{%>
        <option value="6" selected>6th</option>
        <%}else{%>
        <option value="6">6th</option>
        <%}%>
      </select></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Firstname</td>
      <td><select name="fname_con" style="font-size:10px;">
          <%=searchPE.constructGenericDropList(WI.fillTextValue("fname_con"),astrDropListEqual,astrDropListValEqual)%> </select></td>
      <td><input type="text" name="fname" value="<%=WI.fillTextValue("fname")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="12"></td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="4"><strong>Enrollment Date:</strong>
        <input name="doe" type="text" class="textbox" size="10" maxlength="10" value="<%=WI.fillTextValue("doe")%>" readonly="yes">
        <a href="javascript:show_calendar('form_.doe');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a> to 

        <input name="doe2" type="text" class="textbox" size="10" maxlength="10" value="<%=WI.fillTextValue("doe2")%>" readonly="yes">
        <a href="javascript:show_calendar('form_.doe2');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a>	  </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Course</td>
      <td colspan="4"><select name="course_index" style="font-size:11px;background:#DFDBD2;">
        <option value="">&lt;Any&gt;</option>
        <%=dbOP.loadCombo("course_index","course_code+' ::: '+course_name as cname",
                " from course_offered where IS_DEL=0 AND IS_VALID=1 order by cname asc",strTemp, false)%>
      </select></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td><!--Major--></td>
      <td colspan="4"><!--<select name="major_index">
          <option value="">N/A</option>
          <%
//if(WI.fillTextValue("course_index").length()>0){
//strTemp = " from major where IS_DEL=0 and course_index="+request.getParameter("course_index")+" order by major_name asc";
%>
          <%//=dbOP.loadCombo("major_index","major_name"," from major where IS_DEL=0 and course_index="+
 							//request.getParameter("course_index")+" order by major_name asc", request.getParameter("major_index"), false)%> 
          <%//}%>
        </select>-->
        <font size="1">
        <input type="text" name="scroll_course" size="16" style="font-size:9px" class="textbox" 
	  onKeyUp="AutoScrollList('form_.scroll_course','form_.course_index',true);">
(enter course code to scroll course)</font></td>
    </tr>
    
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="5" class="thinborderTOPLEFTRIGHT" bgcolor="#DDDDDD"> <%
strTemp = WI.fillTextValue("show_id");
if(strTemp.compareTo("1") == 0)
	strTemp = " checked";
else	
	strTemp = "";
if(request.getParameter("print_pg") == null)
	strTemp = " checked";
%> <input type="checkbox" name="show_id" value="1"<%=strTemp%>>
        Show ID 
        <%
strTemp = WI.fillTextValue("show_gender");
if(strTemp.compareTo("1") == 0)
	strTemp = " checked";
else	
	strTemp = "";
if(request.getParameter("print_pg") == null)
	strTemp = " checked";
%> <input type="checkbox" name="show_gender" value="1"<%=strTemp%>>
        Show Gender 
         
<%
strTemp = WI.fillTextValue("show_amount");
if(strTemp.compareTo("1") == 0)
	strTemp = " checked";
else	
	strTemp = "";
if(request.getParameter("print_pg") == null)
	strTemp = " checked";
%>
        <input type="checkbox" name="show_amount" value="1"<%=strTemp%>>
        Show Amount Paid </td>
    </tr>
    
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="5" class="thinborderBOTTOMLEFTRIGHT" bgcolor="#DDDDDD"> <%
strTemp = WI.fillTextValue("show_course");
if(strTemp.compareTo("1") == 0 || request.getParameter("print_pg") == null) // first time.
	strTemp = " checked";
else	
	strTemp = "";
%> <input type="checkbox" name="show_course" value="1"<%=strTemp%>>
        Show Course/Major 
        <%
strTemp = WI.fillTextValue("show_yr");
if(strTemp.compareTo("1") == 0)
	strTemp = " checked";
else	
	strTemp = "";
%> <input type="checkbox" name="show_yr" value="1"<%=strTemp%>>
        Show Year Level &nbsp;&nbsp;&nbsp;&nbsp;&nbsp; <!--Name Format: 
        <select name="name_format" style="font-size:11px;font-weight:bold">
          <option value="4">lname, fname mi. (default)</option>
          <%
strTemp = WI.fillTextValue("name_format");
if(strTemp.compareTo("1") == 0) {%>
          <option value="1" selected>fname mname lname</option>
          <%}else{%>
          <option value="1">fname mname lname</option>
          <%}if(strTemp.compareTo("7") == 0) {%>
          <option value="7" selected>fname mi. lname</option>
          <%}else{%>
          <option value="7">fname mi. lname</option>
          <%}if(strTemp.compareTo("5") == 0) {%>
          <option value="5" selected>lname,fname mname</option>
          <%}else{%>
          <option value="5">lname,fname mname</option>
          <%}%>
        </select>--> </td>
    </tr>
    
    <tr> 
      <td height="19" colspan="6"><hr size="1"></td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" id="myADTable3">
    <tr> 
      <td  width="3%" height="25">&nbsp;</td>
      <td width="8%">Sort by</td>
      <td width="27%">
	  <select name="sort_by1" style="font-size:10px">
	 	<option value="">N/A</option>
          <%=searchPE.constructSortByDropList(WI.fillTextValue("sort_by1"),astrSortByName,astrSortByVal)%> 
      </select>
        <select name="sort_by1_con" style="font-size:10px">
          <option value="asc">Asc</option>
<%
if(WI.fillTextValue("sort_by1_con").compareTo("desc") ==0){%>
          <option value="desc" selected>Desc</option>
<%}else{%>
          <option value="desc">Desc</option>
<%}%>
        </select></td>
      <td width="28%"><select name="sort_by2" style="font-size:10px">
	 	<option value="">N/A</option>
          <%=searchPE.constructSortByDropList(WI.fillTextValue("sort_by2"),astrSortByName,astrSortByVal)%> 
        </select> 
        <select name="sort_by2_con" style="font-size:10px">
          <option value="asc">Asc</option>
<%
if(WI.fillTextValue("sort_by2_con").compareTo("desc") ==0){%>
          <option value="desc" selected>Desc</option>
<%}else{%>
          <option value="desc">Desc</option>
<%}%>
        </select></td>
      <td width="34%"><select name="sort_by3" style="font-size:10px">
	 	<option value="">N/A</option>
          <%=searchPE.constructSortByDropList(WI.fillTextValue("sort_by3"),astrSortByName,astrSortByVal)%> 
        </select> 
        <select name="sort_by3_con" style="font-size:10px">
          <option value="asc">Asc</option>
<%
if(WI.fillTextValue("sort_by3_con").compareTo("desc") ==0){%>
          <option value="desc" selected>Desc</option>
<%}else{%>
          <option value="desc">Desc</option>
<%}%>
        </select></td>
      <td width="0%">&nbsp;</td>
    </tr>
    <tr> 
      <td height="18">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td><a href="javascript:Search();"><img src="../../../images/form_proceed.gif" border="0"></a></td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
  </table>
<%
if(vRetResult != null && vRetResult.size() > 0){%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" id="myADTable4">
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25" align="right"><!--<input name="per_course" type="checkbox" value="1">
        <font color="#0000FF" size="1">Print per college</font>-->
      <a href="javascript:PrintPg();"><img src="../../../images/print.gif" border="0"></a><font size="1">click to print </font>&nbsp;</td>
    </tr>
    <tr> 
      <td height="25" colspan="2" bgcolor="#cccccc"><font size="1"><div align="center"><strong>
	  PRE-ENROLLMENT : <%=dbOP.getHETerm(Integer.parseInt(WI.fillTextValue("semester"))).toUpperCase()%>, <%=WI.fillTextValue("sy_from")+" - "+WI.fillTextValue("sy_to")%></strong>
	  <br>
	  Fee name : <%=WI.fillTextValue("fee_name")%>
	  <br>Enrollment Date : 
	  <%=WI.fillTextValue("doe")%><%=WI.getStrValue(WI.fillTextValue("doe2")," to ","","")%>
	  </div></font></td>
    </tr>
   <tr valign="bottom"> 
      <td width="45%" height="22"><b> Total Students : <%=iSearchResult%><!-- - Showing(<%//=searchPE.getDisplayRange()%>)--></b></td>
      <td align="right"><font size="1">Date and time printed : <%=WI.getTodaysDateTime()%></font></td>
    </tr>
  </table>

  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
    <tr> 
      <%if(WI.fillTextValue("show_id").length() > 0) {%>
      <td  width="15%" height="25" class="thinborder"><div align="center"><strong><font size="1">STUDENT 
          ID</font></strong></div></td>
      <%}%>
      <td width="30%" class="thinborder"><div align="center"><strong><font size="1">LNAME, FNAME, MI.</font></strong></div></td>
      <%if(WI.fillTextValue("show_gender").length() > 0) {%>
      <td width="5%" class="thinborder"><div align="center"><strong><font size="1">GENDER</font></strong></div></td>
      <%}if(WI.fillTextValue("show_course").length() > 0) {%>
      <td width="30%" class="thinborder"><div align="center"><strong><font size="1">COURSE/MAJOR</font></strong></div></td>
      <%}if(WI.fillTextValue("show_yr").length() > 0) {%>
      <td width="5%" class="thinborder"><div align="center"><strong><font size="1">YEAR</font></strong></div></td>
      <%}if(WI.fillTextValue("show_amount").length() > 0) {%>
      <td width="15%" class="thinborder"><strong><font size="1">AMOUNT PAID </font></strong></td>
      <%}%>
    </tr>
    <%
boolean bolShowAmt = false; double dTotalCol = 0d;
if(WI.fillTextValue("show_amount").length() > 0) 
	bolShowAmt = true;
for(int i=0; i<vRetResult.size(); i+=10){
	dTotalCol += Double.parseDouble((String)vRetResult.elementAt(i+9));%>
    <tr> 
      <%if(WI.fillTextValue("show_id").length() > 0) {%>
      <td height="20" valign="top" class="thinborder"><font size="1"> 
        <%=(String)vRetResult.elementAt(i+1)%> 
        </font></td>
      <%}%>
      <td height="20" valign="top" class="thinborder"><font size="1">
	  <%=WebInterface.formatName((String)vRetResult.elementAt(i+2),(String)vRetResult.elementAt(i+3),
	  								(String)vRetResult.elementAt(i+4),4)%></font></td>
      <!--<td valign="top" class="thinborder"><font size="1">&nbsp;<%//=(String)vRetResult.elementAt(i+3)%></font></td>
      <td valign="top" class="thinborder">&nbsp;<font size="1"> 
        <%//if(vRetResult.elementAt(i+4) != null && ((String)vRetResult.elementAt(i+4)).length() > 0){%>
        <%//=((String)vRetResult.elementAt(i+4)).charAt(0)%> 
        <%//}%>
        </font></td>-->
      <%if(WI.fillTextValue("show_gender").length() > 0) {%>
      <td valign="top" class="thinborder"><font size="1">&nbsp;<%=WI.getStrValue(vRetResult.elementAt(i+5),"n/f")%></font></td>
      <%}if(WI.fillTextValue("show_course").length() > 0) {%>
      <td valign="top" class="thinborder"><font size="1">&nbsp;<%=(String)vRetResult.elementAt(i+6)%> 
        <%
	  if(vRetResult.elementAt(i+7) != null){%>
        /<%=(String)vRetResult.elementAt(i+7)%> 
        <%}%>
        </font></td>
      <%}if(WI.fillTextValue("show_yr").length() > 0) {%>
      <td valign="top" class="thinborder"><font size="1">&nbsp;<%=WI.getStrValue(vRetResult.elementAt(i+8),"n/a")%></font></td>
      <%}if(bolShowAmt) {%>
      <td class="thinborder" align="right">
	  <font size="1"><%=WI.getStrValue(vRetResult.elementAt(i+9),"&nbsp;")%>&nbsp;&nbsp;&nbsp;</font></td>
      <%}%>
    </tr>
    <%}%>
  </table>
  <table  bgcolor="#FFFFFF"width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="20" align="right">
	    <font size="1"><strong>TOTOAL:&nbsp;&nbsp;<%=CommonUtil.formatFloat(dTotalCol,true)%></strong></font>&nbsp;&nbsp;&nbsp;</td>
    </tr>
  </table>
<%}//vRetResult is not null
%>
  <table  bgcolor="#999900" width="100%" border="0" cellspacing="0" cellpadding="0" id="myADTable5">
  <tr>
    <td height="25" bgcolor="#A49A6A">&nbsp;</td>
  </tr>
</table>
<input type="hidden" name="search_" value="<%=WI.fillTextValue("search_")%>">
<input type="hidden" name="fee_name" value="<%=WI.fillTextValue("fee_name")%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>