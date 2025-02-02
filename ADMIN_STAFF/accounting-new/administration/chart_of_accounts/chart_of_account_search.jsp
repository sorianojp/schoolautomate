<%@ page language="java" import="utility.*,Accounting.Search,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	
	String strFormName = null;
	java.util.StringTokenizer strToken = new java.util.StringTokenizer(WI.fillTextValue("opner_info"),".");
	if(strToken.hasMoreElements()) {
		strFormName = strToken.nextToken();
	
	}
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	
	if (strSchCode == null)
		strSchCode = "";
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>

<script language="JavaScript" src="../../../../jscript/common.js"></script>
<script language="JavaScript">
function PrintPg() {
	document.form_.print_pg.value = "1";
	document.form_.submit();
}
function ReloadPage()
{
	document.form_.search_page.value = "1";
	document.form_.print_pg.value = "";
	document.form_.submit();
}
<%
if(WI.fillTextValue("opner_info").length() > 0){%>
function CopyID(strStudID)
{
	window.opener.document.<%=WI.fillTextValue("opner_info")%>.value=strStudID;
	window.opener.focus();
	<%
	if(strFormName != null){%>
	window.opener.document.<%=strFormName%>.submit();
	<%}%>
	
	self.close();
}
<%}%>
function focusID() {
	document.form_.ac_code.focus();
}
</script>

<body bgcolor="#D2AE72" onLoad="focusID();">
<%
	String strErrMsg = null;
	String strTemp = null;
	Vector vRetResult = null;
	
	if(WI.fillTextValue("print_pg").length() > 0) {%>
		<jsp:forward page="./chart_of_account_search_print.jsp" />
	<%}
	
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Accounting","chart_of_account_search.jsp");
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

int iSearchResult = 0;

Search search = new Search(request);
if(WI.fillTextValue("search_page").compareTo("1") == 0){
	vRetResult = search.searchCOA(dbOP);
	if(vRetResult == null)
		strErrMsg = search.getErrMsg();
	else	
		iSearchResult = search.getSearchCount();
}

%>
<form action="./chart_of_account_search.jsp" method="post" name="form_" onSubmit="SubmitOnceButton(this);">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A"> 
      <td width="100%" height="25" bgcolor="#A49A6A"><div align="center">
	  <font color="#FFFFFF" size="2"><strong>:::: CHART OF ACCOUNTS - SEARCH PAGE ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td height="25" style="font-size:14px; color:#FF0000">&nbsp;&nbsp;&nbsp;<%=WI.getStrValue(strErrMsg)%></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">Classification </td>
      <td width="85%" height="25">
	  <select name="ac_coa_cf">
	  		<option value="">Select a Classification</option>
			<%=dbOP.loadCombo("COA_CF","CF_NAME"," from AC_COA_CF order by COA_CF asc",WI.fillTextValue("ac_coa_cf"), false)%>
      </select></td>
    </tr>
    <tr> 
      <td width="5%" height="25">&nbsp;</td>
      <td width="10%" height="25">Account #</td>
      <td height="25">
	  <select name="ac_code_con">
	  	<option value="">Starts With</option>
<%
strTemp = WI.fillTextValue("ac_code_con");
if(strTemp.length() > 0) 
	strTemp = " selected";
else	
	strTemp = "";
%>
		<option value="1"<%=strTemp%>>Equals</option>
      </select>
      <input name="ac_code" type="text" size="12" maxlength="16" value="<%=WI.fillTextValue("ac_code")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">Account Name</td>
      <td height="25"><select name="acc_name_con">
          <%=search.constructGenericDropList(WI.fillTextValue("acc_name_con"),astrDropListEqual,astrDropListValEqual)%> 
        </select>

        <input name="ac_name" type="text" size="65" maxlength="256" value="<%=WI.fillTextValue("ac_name")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        </td>
    </tr>
    <tr> 
      <td height="38">&nbsp;</td>
      <td height="38">&nbsp;</td>
      <td height="38">
	  <input type="submit" name="12" value=" Search COA " style="font-size:11px; height:28px;border: 1px solid #FF0000;"
		 onClick="document.form_.search_page.value='1';document.form_.print_pg.value=''"></td>
    </tr>
    <tr> 
      <td height="26" colspan="3"><div align="right"></div></td>
    </tr>
  </table>
<%
if(vRetResult != null && vRetResult.size() > 0){%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25"><%
	  if(WI.fillTextValue("opner_info").length() > 0){%>
        NOTE : Please click Account number to copy. 
          <%}%></td>
      <td width="16%" height="25">&nbsp;</td>
      <td width="18%" align="right"><a href="javascript:PrintPg();"><img src="../../../../images/print.gif" border="0"></a> 
        <font size="1">click to print </font>&nbsp;</td>
    </tr>
    <tr> 
      <td height="25" colspan="3" bgcolor="#B9B292"><div align="center"><strong><font color="#FFFFFF">SEARCH 
          RESULT</font></strong></div></td>
    </tr>
    <tr> 
      <td width="66%" ><b> Total Result : <%=iSearchResult%> - Showing(<%=search.getDisplayRange()%>)</b></td>
      <td colspan="2"> <%
	  //if more than one page , constuct page count list here.  - 20 default display per page)
		int iPageCount = iSearchResult/search.defSearchSize;
		if(iSearchResult % search.defSearchSize > 0) ++iPageCount;

		if(iPageCount > 1)
		{%> <div align="right">Jump To page: 
          <select name="jumpto" onChange="ReloadPage();">
            <%
			strTemp = request.getParameter("jumpto");
			if(strTemp == null || strTemp.trim().length() ==0) strTemp = "0";

			for( int i =1; i<= iPageCount; ++i )
			{
				if(i == Integer.parseInt(strTemp) ){%>
            <option selected value="<%=i%>"><%=i%> of <%=iPageCount%></option>
            <%}else{%>
            <option value="<%=i%>"><%=i%> of <%=iPageCount%></option>
            <%
					}
			}
			%>
          </select>
          <%}%>
        </div></td>
    </tr>
  </table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF" class="thinborder">
    <tr align="center" style="font-weight:bold"> 
      <td width="12%" height="25" class="thinborder"><font size="1">CLASSIFICATION</font></td>
      <td width="14%" class="thinborder"><font size="1">ACCOUNT #</font></td>
      <td width="59%" class="thinborder"><font size="1">ACCOUNT NAME</font></td>
      <td width="15%" class="thinborder"><font size="1">STATUS</font></td>
    </tr>
<%
int iHeaderLevel = 1; 
String strIndent = null;
String strRowStyle = null;//if header type, i have to put it in blue color.. 
	
for(int i = 0 ; i < vRetResult.size(); i += 6){ 
	if(vRetResult.elementAt(i + 4).equals("0"))
		strRowStyle = " style='color:#0000FF;'";
	else	
		strRowStyle = "";
	//find indentation.. 
	iHeaderLevel = Integer.parseInt((String)vRetResult.elementAt(i + 5));
	strIndent = "";
	for(int p = 0; p < iHeaderLevel; ++p)
		strIndent = "-"+strIndent;
	strIndent = strIndent + ">";	
	%>	
    <tr<%=strRowStyle%>> 
      <td height="25" class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i)%></td>
      <td class="thinborder">&nbsp;<%=strIndent%> <%=(String)vRetResult.elementAt(i + 2)%></td>
      <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i + 1)%></td>
      <td class="thinborder">&nbsp;<%if(!vRetResult.elementAt(i + 3).equals("1")){%><img src="../../../../images/x.gif"><%}else{%>
	  Active<%}%></td>
    </tr>
<%}%>
  </table>
<%}//show only if vRetResult is not null%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="100%" height="25">&nbsp;</td>
    </tr>
    <tr bgcolor="#B8CDD1"> 
      <td height="25" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
  
<input type="hidden" name="search_page" value="<%=WI.fillTextValue("search_page")%>">
<input type="hidden" name="print_pg">
<!-- Instruction -- set the opner_from_name to the parent window to copy the student ID -->
<input type="hidden" name="opner_info" value="<%=WI.fillTextValue("opner_info")%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>