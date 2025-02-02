<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/td.js"></script>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
function PrintPg()
{
	document.form_.print_pg.value = "1";
	document.form_.submit();
}
function ReloadPage()
{
	document.form_.print_pg.value = "";
	document.form_.reloadPage.value = "1";
	document.form_.submit();
}
function ShowResult() {
	document.form_.print_pg.value = "";
	document.form_.reloadPage.value = "";
	document.form_.submit();
}
</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strTemp = null;
	int iSubTotal   = 0; // sub total of a course - major.

if(WI.fillTextValue("print_pg").length() > 0) {%>
			<jsp:forward page="./list_stud_paid_full_print.jsp" />
<%}//forward the page to print .


	String strErrMsg = null;
//add security here.
	try {
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments-REPORTS","list_stud_paid_full.jsp");
	}
	catch(Exception exp) {
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
														"list_stud_paid_full.jsp");
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
String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";

//end of authenticaion code.
boolean bolIsUC = strSchCode.startsWith("UC");

Vector vRetResult = null;
if(WI.fillTextValue("sy_from").length() > 0 && WI.fillTextValue("sy_to").length() > 0 && WI.fillTextValue("reloadPage").length() ==0) {
	enrollment.ReportFeeAssessment REA = new enrollment.ReportFeeAssessment();
	if(bolIsUC)
		vRetResult = REA.getStudListPaidFullUC(dbOP, request);
	else	
		vRetResult = REA.getStudListPaidFull(dbOP, request);
	if(vRetResult == null)
		strErrMsg = REA.getErrMsg();	
}
String[] astrSortByName    = {"ID #","Lastname","Firstname","Gender","Year Level"};
String[] astrSortByVal     = {"id_number","lname","fname","gender","stud_curriculum_hist.year_level"};

String[] astrConvertToSem = {"SUMMER, ","FIRST SEMESTER, ","SECOND SEMESTER, ",
						"THIRD SEMESTER, ","FOURTH SEMESTER, "};

%>
<form action="./list_stud_paid_full.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25" colspan="4" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>:::: 
          LIST OF STUDENTS PAID FULL ::::</strong></font></div></td>
    </tr>
  </table>

  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="1%" height="25"></td>
      <td colspan="5"><strong><%=WI.getStrValue(strErrMsg)%></strong></td>
    </tr>
    <tr>
      <td height="25"></td>
      <td colspan="5" style="font-weight:bold; font-size:11px; color:#0000FF">
	  <input type="checkbox" name="is_basic" value="checked" <%=WI.fillTextValue("is_basic")%>> Process Grade School </td>
    </tr>
    <tr> 
      <td height="25"></td>
      <td colspan="4">School Year/Term 
        <%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%> <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
        - 
        <%
strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%> <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes">
        - 
        <select name="semester">
          <option value="">ALL</option>
          <%
strTemp = WI.fillTextValue("semester");
if(strTemp.length() ==0 && WI.fillTextValue("page_value").length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sem");
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
        </select>      </td>

      <td align="right">
<%if(strSchCode.startsWith("SPC") || strSchCode.startsWith("NEU") || strSchCode.startsWith("DLSHSI")){%>
	  	<a href="./list_stud_with_late_fine_spc.jsp">Go to Late Fine Listing</a>
<%}%>
	  </td>
    </tr>
    <tr>
      <td height="25"></td>
      <td colspan="5"> &nbsp;&nbsp;NOTE : If discount amount is incorrect, please 
        re-create receivable projection table.</td>
    </tr>
    <tr> 
      <td height="25"></td>
      <td colspan="5"><strong>Show By :</strong>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
<font color="#0000FF">
<%if(strSchCode.startsWith("CGH")){//cgh does not have full pmt discount.. it has late pmt surcharge only.
strTemp = WI.fillTextValue("remove_surcharge");
if(strTemp.compareTo("1") == 0) 
	strTemp  = " checked";
else	
	strTemp = "";
%>
Remove Late surcharge payment <input name="remove_surcharge" type="checkbox" value="1" <%=strTemp%>>
<%}else{//show for other school as cgh does not have full pmt discount.. 
strTemp = WI.fillTextValue("show_only_disc");
if(strTemp.compareTo("1") == 0) 
	strTemp  = " checked";
else	
	strTemp = "";
%> <input name="show_only_disc" type="checkbox" value="1" <%=strTemp%>>
        Show only students with full pmt. discount. 
        <%
strTemp = WI.fillTextValue("show_discount");
if(strTemp.compareTo("1") == 0) 
	strTemp  = " checked";
else	
	strTemp = "";
%>
        <input name="show_discount" type="checkbox" value="1" <%=strTemp%>>
        Show discount amount
		
<%}%>
</font></td>
    </tr>
    <tr> 
      <td height="25"></td>
      <td width="1%">&nbsp;</td>
      <td width="16%">College/School </td>
      <td colspan="3"><select name="c_index" onChange="ReloadPage();">
          <option value="">All</option>
          <%=dbOP.loadCombo("c_index","c_name"," from college where IS_DEL=0 order by c_name asc",
		  		request.getParameter("c_index"), false)%> </select> </td>
    </tr>
    <tr> 
      <td height="31"></td>
      <td></td>
      <td>Course</td>
      <td colspan="3"><select name="course_index" onChange="ReloadPage();">
          <option value="">All</option>
          <%
strTemp = WI.fillTextValue("c_index");
if(strTemp.length() > 0){%>
          <%=dbOP.loadCombo("course_index","course_name"," from course_offered where IS_DEL=0 and is_valid=1 and c_index="+strTemp+" order by course_name asc",
		  		request.getParameter("course_index"), false)%> 
          <%}%>
        </select> </td>
    </tr>
    <tr> 
      <td height="25"></td>
      <td></td>
      <td>Major</td>
      <td colspan="3"><select name="major_index" onChange="ReloadPage();">
          <option></option>
          <%
strTemp = WI.fillTextValue("course_index");
if(strTemp.compareTo("0") != 0 && strTemp.length() > 0)
{
strTemp = " from major where is_del=0 and course_index="+strTemp ;
%>
          <%=dbOP.loadCombo("major_index","major_name",strTemp, request.getParameter("major_index"), false)%> 
          <%}%>
        </select></td>
    </tr>
    <tr> 
      <td height="25"></td>
      <td></td>
      <td>Year Level</td>
      <td colspan="3"><select name="year_level">
          <option value="">All</option>
          <%
strTemp =WI.fillTextValue("year_level");
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
        </select> </td>
    </tr>
    <tr id="row_3"> 
      <td height="25"></td>
      <td></td>
      <td>Student ID </td>
      <td width="18%"><input name="id_number" type="text" size="16" value="<%=WI.fillTextValue("id_number")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">      </td>
      <td colspan="2">&nbsp;</td>
    </tr>
    <tr id="row_2"> 
      <td height="25"></td>
      <td></td>
      <td>Sort Result by</td>
      <td width="18%"><select name="sort_by1">
          <option value="">N/A</option>
          <%=new ConstructSearch().constructSortByDropList(WI.fillTextValue("sort_by1"),astrSortByName,astrSortByVal)%> </select> <br> <select name="sort_by1_con">
          <option value="asc">Ascending</option>
          <%
if(WI.fillTextValue("sort_by1_con").compareTo("desc") ==0){%>
          <option value="desc" selected>Descending</option>
          <%}else{%>
          <option value="desc">Descending</option>
          <%}%>
        </select> </td>
      <td width="27%"><select name="sort_by2">
          <option value="">N/A</option>
          <%=new ConstructSearch().constructSortByDropList(WI.fillTextValue("sort_by2"),astrSortByName,astrSortByVal)%> </select> <br> <select name="sort_by2_con">
          <option value="asc">Ascending</option>
          <%
if(WI.fillTextValue("sort_by2_con").compareTo("desc") ==0){%>
          <option value="desc" selected>Descending</option>
          <%}else{%>
          <option value="desc">Descending</option>
          <%}%>
        </select></td>
      <td width="37%" valign="bottom"> <a href="javascript:ShowResult();"><img src="../../../images/refresh.gif" border="0"></a></td>
    </tr>
    <tr> 
      <td height="25"></td>
      <td colspan="2"></td>
      <td>&nbsp;</td>
      <td colspan="2">&nbsp;</td>
    </tr>
  </table>
<%
boolean bolShowDiscAmount = false;

if(bolIsUC)
	bolShowDiscAmount = true;
	
if(WI.fillTextValue("show_only_disc").length() > 0 && WI.fillTextValue("show_discount").length() > 0)
	bolShowDiscAmount  = true;
double dPerCollegePmt  = 0d;
double dPerCollegeDisc = 0d;	

double dTotalPmt       = 0d;
double dTotalDisc      = 0d;

double dTemp = 0d;
if(vRetResult != null){
    boolean bolIsBasic = false;
    if(WI.fillTextValue("is_basic").length() > 0) {
      bolIsBasic = true;
    }    

%>

  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td><div align="right"><font size="1"><a href="javascript:PrintPg();"><img src="../../../images/print.gif" border="0"></a> 
          Click to print&nbsp;&nbsp;&nbsp;</font></div></td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" colspan="4" bgcolor="#C2BEA3"><div align="center"><strong>::: 
          LIST OF STUDENT PAID IN FULL FOR <%=astrConvertToSem[Integer.parseInt(WI.fillTextValue("semester"))]+ WI.fillTextValue("sy_from")+" - "+WI.fillTextValue("sy_to")%> :::</strong></div></td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
    <tr> 
      <td width="20%" height="24" class="thinborder"><font size="1"><strong>STUDENT 
        ID</strong></font></td>
      <td width="44%" class="thinborder"><font size="1"><strong>NAME (LNAME,FNAME, MI)</strong></font></td>
      <td width="12%" class="thinborder"><font size="1"><strong>YEAR LEVEL</strong></font></td>
      <td width="24%" class="thinborder"><font size="1"><strong><%if(bolIsUC){%>DATE PAID<%}else{%>AMOUNT PAID<%}%></strong></font></td>
      <%if(bolShowDiscAmount){%>
      <td width="24%" class="thinborder"><font size="1"><strong>DISCOUNT AMOUNT</strong></font></td>
      <%}%>
    </tr>
    <%
for(int i = 0; i< vRetResult.size() ; i +=9){
if(vRetResult.elementAt(i + 1) != null) {if(i > 0) {%>
    <tr> 
      <td height="20" colspan="3" class="thinborder" align="right"><strong>SUB 
        TOTAL&nbsp;&nbsp;</strong></td>
      <td height="20" class="thinborder" align="right"><%if(!bolIsUC){%><%=CommonUtil.formatFloat(dPerCollegePmt,true)%><%}%> &nbsp;&nbsp; </td>
<%if(bolShowDiscAmount){%>
      <td height="20" class="thinborder" align="right"><%=CommonUtil.formatFloat(dPerCollegeDisc,true)%></td>
<%}%>
    </tr>
    <%dPerCollegePmt=0d;dPerCollegeDisc=0d;}%>
    <tr bgcolor="#EFEFEF"> 
      <td height="20" colspan="4" class="thinborderBOTTOMLEFT"><strong>COLLEGE 
        : <%=(String)vRetResult.elementAt(i + 1)%></strong></td>
<%if(bolShowDiscAmount){%>
      <td height="20" class="thinborderBOTTOM">&nbsp;</td>
<%}%>
    </tr>
    <%}
	if(vRetResult.elementAt(i + 2) != null || vRetResult.elementAt(i + 3) != null) {%>
    <tr> 
      <td height="24" colspan="4" class="thinborderBOTTOMLEFT"><font size="1" color="#0000FF">::Course::Major: 
        <%=(String)vRetResult.elementAt(i + 2)%> <%=WI.getStrValue(vRetResult.elementAt(i + 3))%></font></td>
<%if(bolShowDiscAmount){%>
      <td height="24" class="thinborderBOTTOM">&nbsp;</td>
<%}%>
    </tr>
    <%}
if(!bolIsUC) {
	dTemp = Double.parseDouble(WI.getStrValue(vRetResult.elementAt(i + 7),"0"));
	dPerCollegePmt += dTemp;
	dTotalPmt      += dTemp;
}
dTemp = Double.parseDouble(WI.getStrValue(vRetResult.elementAt(i + 8),"0"));
dPerCollegeDisc += dTemp;
dTotalDisc      += dTemp;
	%>
    <tr> 
      <td width="20%" height="24" class="thinborder"><%=(String)vRetResult.elementAt(i + 4)%></td>
      <td width="44%" class="thinborder"><%=(String)vRetResult.elementAt(i + 5)%></td>
      <td width="12%" class="thinborder"><%if(bolIsBasic) {%>&nbsp;<%}else{%><%=WI.getStrValue(vRetResult.elementAt(i + 6),"&nbsp;")%><%}%></td>
      <td width="24%" class="thinborder" align="right"> 
	  <%if(vRetResult.elementAt(i + 7) != null){
	  	if(bolIsUC){%> 
			<%=vRetResult.elementAt(i + 7)%>
		<%}else{%>
	  		<%=CommonUtil.formatFloat(Double.parseDouble((String)vRetResult.elementAt(i + 7)),true)%> 
	  <%}}
	  else{%> &nbsp;&nbsp; <%}//=WI.getStrValue(vRetResult.elementAt(i + 7),"&nbsp;")%> </td>
<%if(bolShowDiscAmount){%>
      <td width="24%" class="thinborder" align="right"> <%if(vRetResult.elementAt(i + 8) != null){%> <%=CommonUtil.formatFloat(((Double)vRetResult.elementAt(i + 8)).doubleValue(),true)%> <%}else{%> &nbsp;&nbsp;<%}%></td>
<%}%>
    </tr>
    <%}//end of for loop%>
    <tr> 
      <td height="20" colspan="3" class="thinborder" align="right"><strong>SUB 
        TOTAL&nbsp;&nbsp;</strong></td>
      <td height="20" class="thinborder" align="right"><%if(!bolIsUC){%><%=CommonUtil.formatFloat(dPerCollegePmt,true)%><%}%> &nbsp;&nbsp; </td>
<%if(bolShowDiscAmount){%>
      <td height="20" class="thinborder" align="right"><%=CommonUtil.formatFloat(dPerCollegeDisc,true)%></td>
<%}%>
    </tr>
  </table>
   
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="25%" height="24" align="right">Total No. of Student(s) : 
      </td>
      <td width="9%"><strong><%=vRetResult.size()/9%></strong></td>
      <td width="66%"><%if(!bolIsUC){%>Total Payment:<%=CommonUtil.formatFloat(dTotalPmt,true)%><%}%>&nbsp;&nbsp;&nbsp;&nbsp; 
<%if(bolShowDiscAmount){%>
	  Total Discount: <%=CommonUtil.formatFloat(dTotalDisc,true)%><%}%></td>
    </tr>
  </table>
 <%}//end if vRetResult is not null
 %>
   <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25">&nbsp;</td>
    </tr>
    <tr bgcolor="#B8CDD1">
      <td height="25" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>

<input type="hidden" name="reloadPage">
<input type="hidden" name="print_pg">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>