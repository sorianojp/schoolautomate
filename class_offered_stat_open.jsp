<%
String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";
	
	
String strShowClassProgView = new utility.ReadPropertyFile().getImageFileExtn("STUDENT_VIEW_CLASSPROG","0");

if(strShowClassProgView == null || !strShowClassProgView.equals("1")) {%>
	<p style="font-family:Verdana, Arial, Helvetica, sans-serif; font-size:24px; font-weight:bold; color:#FF0000">
		Class program view is not open for student access.
	</p>
<%return;}
//System.out.println(strShowClassProgView);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="./css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="./css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script src="./Ajax/ajax.js"></script>
<script language="JavaScript">
	function DisplayAll(){
		if(document.form_.sub_index.selectedIndex <0) {
			alert("Subject list is empty");
			return;
		}
		document.form_.showAll.value = "1";
		document.form_.submit();
	}

function PageSubmit(e) {//submit page on ENTER
	if(e.keyCode == 13) 
		DisplayAll();
}
function AjaxSearchSubject(e) {
	if(e.keyCode == 13) {
		DisplayAll();
		return;
	}
	
	
	var strSubject;
	
	strSubject = document.form_.scroll_sub.value;
	if(strSubject.length < 3) {
		//document.getElementById("coa_info").innerHTML = "";
		return;
	}
	var objCOAInput = document.getElementById("coa_info");

	this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
	if(this.xmlHttp == null) {
		alert("Failed to init xmlHttp.");
		return;
	}
	var strURL = "./Ajax/AjaxInterface.jsp?methodRef=129&subject="+escape(strSubject)+"&sel_name=sub_index&offering_syf="+document.form_.sy_from.value+
					"&offering_sem="+document.form_.semester.value+"&onchange=DisplayAll";

	this.processRequest(strURL);
		//document.getElementById("coa_info").innerHTML=this.strPrevEntry+this.bolReturnStrEmpty
}
function Focus() {
	document.form_.scroll_sub.focus();
	textField = document.form_.scroll_sub;
	var endIndex = textField.value.length;
	if (textField.setSelectionRange) {
   		textField.setSelectionRange(endIndex, endIndex);
	}
}

</script>
<body bgcolor="#9FBFD0" onLoad="Focus()">
<%@ page language="java" import="utility.*,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	WebInterface WI = new WebInterface(request);

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

if(request.getSession(false).getAttribute("userIndex") == null) {
	request.getSession(false).setAttribute("userIndex", "0");
}
Vector vRetResult = null; Vector vAddlInfo = null; int iIndexOf = 0; String strCapacity = null;
enrollment.SubjectSection SS = new enrollment.SubjectSection();
if (WI.fillTextValue("showAll").length() >  0) {
	vRetResult = SS.operateOnCPPerSub(dbOP, request,4);
	if (vRetResult == null || vRetResult.size() == 0)
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
	
String[] astrCurSYTerm = dbOP.getCurSchYr();

%>

<form name="form_" action="./class_offered_stat_open.jsp" method="post">
<table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#47768F">
      <td height="25" colspan="6"><div align="center"><font color="#FFFFFF"><strong>:::: 
          CLASS OFFERING - PER SUBJECT ::::</strong></font></div></td>
    </tr>
  </table>

  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
<%if(strErrMsg != null) {%>
    <tr> 
      <td width="2%">&nbsp;</td>
      <td height="25" colspan="3"><strong><font size="3"><%=WI.getStrValue(strErrMsg,"")%></font></strong></td>
    </tr>
<%}%>
    <tr> 
      <td>&nbsp;</td>
      <td colspan="3" style="font-size:20px;">SY-Term:  
        <%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() ==0)
	strTemp = astrCurSYTerm[0];

strSYFrom = strTemp;%> <input name="sy_from" type="text" class="textbox_noborder" id="sy_from"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;" style='font-size:20px;'
	  onKeyUp='DisplaySYTo("form_","sy_from","sy_to")' value="<%=strTemp%>" size="4" maxlength="4" readonly='yes'>
        -  
<%
strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() ==0)
	strTemp =  astrCurSYTerm[1];
%> <input name="sy_to" type="text" class="textbox_noborder" id="sy_to" style='font-size:20px;'
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=strTemp%>" size="4" maxlength="4"
	  readonly="yes"> - 
<%
strTemp = WI.fillTextValue("semester");
if(strTemp.length() ==0)
	strTemp =  astrCurSYTerm[2];

strSem = strTemp;
%>
<input type="hidden" name="semester" value="<%=strSem%>">
        <select name="semester_" disabled="disabled" style="font-size:20px; font-weight:bold; color:#000000">
          <!-- onChange="document.form_.showAll.value='';document.form_.submit();">-->
          <%=CommonUtil.constructTermList(dbOP, request, strTemp)%>
      </select> </td>
    </tr>
    <tr> 
      <td colspan="4"><hr size="1"></td>
    </tr>
<!--
    <tr> 
      <td>&nbsp;</td>
      <td colspan="2" valign="bottom">
	  Auto Scroll for 
	  <select name="auto_scr" onChange="document.form_.showAll.value='';document.form_.submit();">
		  <option value="1">Subject Code</option>
<%
strTemp = WI.fillTextValue("auto_scr");
if(strTemp.equals("2"))
	strTemp = " selected";
else	
	strTemp = "";
%>
		  <option value="2" <%=strTemp%>>Subject Title</option>
	  </select>
	  
	  : &nbsp;&nbsp;<font size="1"> 
        <input type="text" name="scroll_sub" size="16" style="font-size:9px" 
	  onKeyUp="AutoScrollList('form_.scroll_sub','form_.sub_index',true); PageSubmit(event);">
        (enter subject code to scroll the list)</font></td>
    </tr>
-->
    <tr> 
      <td>&nbsp;</td>
      <td width="11%" height="35">
	  Search Offering </td>
      <td width="43%"><input type="text" name="scroll_sub" size="32" style="font-size:15px" 
	   onKeyUp="AjaxSearchSubject(event);" value="<%=WI.fillTextValue("scroll_sub")%>"  autocomplete="off">
        <font size="1">(Press Enter or proceed to Display Result)</font></td>
      <td width="44%"><a href="javascript: DisplayAll()"><img src="./images/form_proceed.gif"border="0"></a></td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td valign="bottom">
	   
	  Subject	offered </td>
      <td colspan="2" valign="bottom">
	  <label id="coa_info">
	  <select name="sub_index" title="SELECT A  SUBJECT"
	  	style="font-size:11px;font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; width:600px;" onChange="DisplayAll()">
        <%
strTemp = WI.fillTextValue("auto_scr");
//if(strTemp.equals("1"))
	strTemp = "sub_code +'&nbsp;&nbsp;&nbsp;('+sub_name+')' as s_code";
//else	
//	strTemp = "sub_name +'&nbsp;&nbsp;&nbsp;('+sub_code+')' as s_code";

strErrMsg = "";
if(WI. fillTextValue("scroll_sub").length() > 0) {
	strErrMsg = utility.ConversionTable.replaceString(WI.fillTextValue("scroll_sub"), "'", "''");
	strErrMsg = " and (sub_code like '%"+strErrMsg+"%' or sub_name like '%"+strErrMsg+"%') ";
}
%>
        <%=dbOP.loadCombo("sub_index",strTemp," from subject where is_del=0 "+
		  		" and exists (select * from e_sub_section where sub_index = subject.sub_index and e_sub_section.is_valid = 1 and "+
				"offering_sy_from = "+strSYFrom+" and offering_sem = "+strSem+" and IS_CHILD_OFFERING = 0 and is_lec = 0) "+strErrMsg+" order by s_code",WI.fillTextValue("sub_index"), false)%>
      </select>
	  </label></td>
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
      <td width="60%" height="25" style="font-size:15px;">&nbsp;&nbsp; <strong>Total Schedules Found: 
        <%=vRetResult.size()/11%></strong></td>
      <td width="40%">&nbsp;</td>
    </tr>
  </table>  
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#BECED3"> 
      <td height="25" colspan="12" class="thinborder" style="font-weight:bold"><div align="center">FINAL SCHEDULE OF CLASSES<strong></strong></div></td>
    </tr>
  </table>  
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr align="center" style="font-weight:bold">
<%if(bolIsPhilCST){%>
      <td width="5%" class="thinborder" style="font-size:9px; font-weight:bold" align="center"><font style="font-size:12px;">OFFERING CODE</font></td> 
      <%}%>
      <td width="11%" class="thinborder"><font style="font-size:12px;">OFFERED BY</font></td>
      <td width="11%" height="25" class="thinborder"><font style="font-size:12px;">SUBJECT CODE</font></td>
      <td width="19%" class="thinborder"><font style="font-size:12px;">DESCRIPTION</font></td>
      <td width="5%" class="thinborder"><font style="font-size:12px;">TOTAL UNITS</font></td>
      <td width="10%" class="thinborder"><font style="font-size:12px;">SECTION</font></div></td>
      <td class="thinborder"><font style="font-size:12px;">SCHEDULE</font></div></td>
      <td width="5%" class="thinborder"><font style="font-size:12px;">ROOM #</font></div></td>
      <td width="5%" class="thinborder"><font style="font-size:12px;"># Enrolled</font></td>
<%if(bolAllowAdjustCapacity){%>
      <td width="4%" class="thinborder"><font style="font-size:12px;">Capacity</font></td>
<%}%>
       <td width="5%" class="thinborder" align="center"><font style="font-size:12px;">Is Reserved?</font></td>
     <td width="5%" height="25" class="thinborder"><font style="font-size:12px;">Is Closed?</font></td>
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
			value="<%=WI.getStrValue( SS.convertSubSecIndexToOfferingCount(dbOP, request, (String)vRetResult.elementAt(i+4), strSYFrom, strSem, strSchCode))%>"
			onfocus="style.backgroundColor='#D3EBFF'">
	  </td> 
      <%}
	  strErrMsg = (String)vRetResult.elementAt(i+3);
	  if(strErrMsg.length() > 25)
	  	strErrMsg = strErrMsg.substring(0,25)+"....";
	  
	  %>
      <td class="thinborder" style="font-size:15px;"><%=WI.getStrValue(vRetResult.elementAt(i + 12), "&nbsp;")%></td>
      <td height="30" class="thinborder" style="font-size:15px;"><%=(String)vRetResult.elementAt(i+2)%></td>
      <td class="thinborder" style="font-size:15px;"><%=strErrMsg%></td>
      <td class="thinborder" style="font-size:15px;"><%=strTotalUnits%></td>
      <td class="thinborder" style="font-size:15px;"><%=(String)vRetResult.elementAt(i+1)%></td>
      <td class="thinborder" style="font-size:15px;"><%=(String)vRetResult.elementAt(i+5)%></td>
      <td class="thinborder" style="font-size:15px;"><%=(String)vRetResult.elementAt(i+7)%></td>
      <td class="thinborder" style="font-size:15px;"><%=vRetResult.elementAt(i + 10)%></td>
<%if(bolAllowAdjustCapacity){%>
      <td class="thinborder" align="center" style="font-size:15px;"><%=strCapacity%></td>
<%}%>      <td class="thinborder" align="center" style="font-size:15px;"><font style="font-weight:bold; font-size:16px; color:#FF0000"><%=strTemp%></font></td>
      <td class="thinborder" align="center" style="font-size:15px;"><font style="font-weight:bold; font-size:16px; color:#FF0000"><%=strIsClosed%></font></td>
    </tr>
    <%}//end for loop %>
  </table>
<%} // if (vRetResult != null && vRetResult.size() > 0)%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF">
    <tr > 
      <td height="25">&nbsp;</td>
    </tr>
    <tr bgcolor="#47768F"> 
      <td height="25" >&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="showAll">


<!-- add in pages with subject scroll -->
<%//=dbOP.constructAutoScrollHiddenField()%>

</form>

</body>
</html>
<%
dbOP.cleanUP();
%>
